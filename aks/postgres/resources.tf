locals {
  database_name = "${var.service_short}_${var.environment}"

  name_suffix = var.name != null ? "-${var.name}" : ""

  azure_name                  = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-pg${local.name_suffix}"
  azure_private_endpoint_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-pg${local.name_suffix}-pe"
  azure_enable_backup_storage = var.use_azure && var.azure_enable_backup_storage
  azure_enable_monitoring     = var.use_azure && var.azure_enable_monitoring

  kubernetes_name = "${var.service_name}-${var.environment}-postgres${local.name_suffix}"
}

# Username & password

resource "random_string" "username" {
  count = var.admin_username == null ? 1 : 0

  length  = 15
  special = false
  upper   = false
}

resource "random_password" "password" {
  count = var.admin_password == null ? 1 : 0

  length  = 32
  special = true
}

locals {
  database_username = var.admin_username != null ? var.admin_username : "u${random_string.username[0].result}"
  database_password = var.admin_password != null ? var.admin_password : random_password.password[0].result
}

# Azure

resource "azurerm_postgresql_flexible_server" "main" {
  count = var.use_azure ? 1 : 0

  name                   = local.azure_name
  location               = data.azurerm_resource_group.main[0].location
  resource_group_name    = data.azurerm_resource_group.main[0].name
  version                = var.server_version
  administrator_login    = local.database_username
  administrator_password = local.database_password
  create_mode            = "Default"
  storage_mb             = var.azure_storage_mb
  sku_name               = var.azure_sku_name
  delegated_subnet_id    = data.azurerm_subnet.main[0].id
  private_dns_zone_id    = data.azurerm_private_dns_zone.main[0].id

  dynamic "high_availability" {
    for_each = var.azure_enable_high_availability ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  dynamic "maintenance_window" {
    for_each = var.azure_maintenance_window != null ? [var.azure_maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      # Allow Azure to manage deployment zone. Ignore changes.
      zone,
      # Allow Azure to manage primary and standby server on fail-over. Ignore changes.
      high_availability[0].standby_availability_zone,
      # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
      create_mode
    ]
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "azure_extensions" {
  count = var.use_azure && length(var.azure_extensions) > 0 ? 1 : 0

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.main[0].id
  value     = join(",", var.azure_extensions)
}

resource "azurerm_postgresql_flexible_server_configuration" "max_connections" {
  count = var.use_azure ? 1 : 0

  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.main[0].id
  value     = 856 # Maximum on GP_Standard_D2ds_v4. See: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-limits#maximum-connections
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  count = var.use_azure ? 1 : 0

  name      = local.database_name
  server_id = azurerm_postgresql_flexible_server.main[0].id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_storage_account" "backup" {
  count = local.azure_enable_backup_storage ? 1 : 0

  name                            = "${var.azure_resource_prefix}${var.service_short}dbbkp${var.config_short}sa"
  location                        = data.azurerm_resource_group.main[0].location
  resource_group_name             = data.azurerm_resource_group.main[0].name
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  allow_nested_items_to_be_public = false

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_storage_management_policy" "backup" {
  count = local.azure_enable_backup_storage ? 1 : 0

  storage_account_id = azurerm_storage_account.backup[0].id

  rule {
    name    = "DeleteAfter7Days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }
}

resource "azurerm_storage_container" "backup" {
  count = local.azure_enable_backup_storage ? 1 : 0

  name                  = "database-backup"
  storage_account_name  = azurerm_storage_account.backup[0].name
  container_access_type = "private"
}

resource "azurerm_monitor_metric_alert" "memory" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_postgresql_flexible_server.main[0].name}-memory"
  resource_group_name = data.azurerm_resource_group.main[0].name
  scopes              = [azurerm_postgresql_flexible_server.main[0].id]
  description         = "Action will be triggered when memory use is greater than 75%"
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_memory_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_postgresql_flexible_server.main[0].name}-cpu"
  resource_group_name = data.azurerm_resource_group.main[0].name
  scopes              = [azurerm_postgresql_flexible_server.main[0].id]
  description         = "Action will be triggered when cpu use is greater than 60%"
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_cpu_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "storage" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_postgresql_flexible_server.main[0].name}-storage"
  resource_group_name = data.azurerm_resource_group.main[0].name
  scopes              = [azurerm_postgresql_flexible_server.main[0].id]
  description         = "Action will be triggered when storage use is greater than 75%"
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_storage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Kubernetes

resource "kubernetes_deployment" "main" {
  count = var.use_azure ? 0 : 1

  metadata {
    name      = local.kubernetes_name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.kubernetes_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.kubernetes_name
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os" : "linux"
        }
        container {
          name  = local.kubernetes_name
          image = var.server_docker_image
          resources {
            requests = {
              cpu    = var.cluster_configuration_map.cpu_min
              memory = "256Mi"
            }
            limits = {
              cpu    = 1
              memory = "1Gi"
            }
          }
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_USER"
            value = local.database_username
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = local.database_password
          }
          env {
            name  = "POSTGRES_DB"
            value = local.database_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "main" {
  count = var.use_azure ? 0 : 1

  metadata {
    name      = local.kubernetes_name
    namespace = var.namespace
  }
  spec {
    port {
      port = 5432
    }
    selector = {
      app = local.kubernetes_name
    }
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_postgresql_flexible_server.main[0].name}-log"
  location            = data.azurerm_resource_group.main[0].location
  resource_group_name = data.azurerm_resource_group.main[0].name
  sku                 = "PerGB2018"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                       = "${azurerm_postgresql_flexible_server.main[0].name}-diagnotics"
  target_resource_id         = azurerm_postgresql_flexible_server.main[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.main[0].log_category_types
    content {
      category = enabled_log.value
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      enabled = false
    }
  }
}
