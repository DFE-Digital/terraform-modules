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

resource "azurerm_key_vault_secret" "sql_admin_username" {
  name         = upper("${local.resource_prefix}-${var.server_name_suffix}-sql-admin-username")
  value        = local.database_username
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = upper("${local.resource_prefix}-${var.server_name_suffix}-sql-admin-password")
  value        = local.database_password
  key_vault_id = var.key_vault_id
}

resource "azurerm_mssql_server" "main" {
  name                = "${local.resource_prefix}-${var.server_name_suffix}-sql"
  resource_group_name = data.azurerm_resource_group.main[0].name
  location            = data.azurerm_resource_group.main[0].location
  version             = var.server_version

  administrator_login          = local.database_username
  administrator_login_password = local.database_password

  public_network_access_enabled            = var.public_network_access_enabled
  express_vulnerability_assessment_enabled = var.express_vulnerability_assessment_enabled

  dynamic "azuread_administrator" {
    for_each = var.entra_admin == "" ? [] : [var.entra_admin]

    content {
      login_username = data.azuread_group.sql_entra_admin[0].display_name
      object_id      = data.azuread_group.sql_entra_admin[0].object_id
    }
  }

  lifecycle {
    ignore_changes = [tags, azuread_administrator]
  }
}

resource "azurerm_private_endpoint" "sql" {
  count = var.azure_sql_private_endpoint_enabled ? 1 : 0

  name                = "${azurerm_mssql_server.main.name}-pe"
  location            = data.azurerm_resource_group.main[0].location
  resource_group_name = data.azurerm_resource_group.main[0].name
  subnet_id           = data.azurerm_subnet.sql[0].id

  private_service_connection {
    name                           = "${azurerm_mssql_server.main.name}-pe"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.sql[0].name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sql[0].id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_mssql_database" "main" {
  for_each = var.databases

  name      = "${local.resource_prefix}-${each.value.server_name_suffix}-sql-db"
  server_id = azurerm_mssql_server.main.id

  sku_name             = var.azure_sql_sku
  storage_account_type = var.storage_account_type

  zone_redundant = var.zone_redundant

  long_term_retention_policy {
    monthly_retention = var.lt_ret_pol_monthly_retention
    week_of_year      = var.lt_ret_pol_week_of_year
    weekly_retention  = var.lt_ret_pol_weekly_retention
    yearly_retention  = var.lt_ret_pol_yearly_retention
  }

  short_term_retention_policy {
    backup_interval_in_hours = var.st_ret_pol_backup_interval_in_hours
    retention_days           = var.st_ret_pol_retention_days
  }

  threat_detection_policy {
    disabled_alerts            = []
    email_addresses            = []
    retention_days             = 0
    state                      = "Disabled"
    storage_account_access_key = null
    storage_endpoint           = null
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_mssql_database" "extra" {
  for_each = toset(local.extra_database_names)

  name      = each.value
  server_id = azurerm_mssql_server.main.id

  sku_name             = var.azure_sql_sku
  storage_account_type = var.storage_account_type

  zone_redundant = var.zone_redundant

  long_term_retention_policy {
    monthly_retention = var.lt_ret_pol_monthly_retention
    week_of_year      = var.lt_ret_pol_week_of_year
    weekly_retention  = var.lt_ret_pol_weekly_retention
    yearly_retention  = var.lt_ret_pol_yearly_retention
  }

  short_term_retention_policy {
    backup_interval_in_hours = var.st_ret_pol_backup_interval_in_hours
    retention_days           = var.st_ret_pol_retention_days
  }

  threat_detection_policy {
    disabled_alerts            = []
    email_addresses            = []
    retention_days             = 0
    state                      = "Disabled"
    storage_account_access_key = null
    storage_endpoint           = null
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each = {
    for rule in var.firewall_rules :
    rule.name => rule
  }

  name             = each.value.name
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = coalesce(each.value.start_ip_address, each.value.ip_address)
  end_ip_address   = coalesce(each.value.end_ip_address, each.value.ip_address)
}

resource "azurerm_monitor_metric_alert" "cpu" {
  # count = var.azure_enable_monitoring ? 1 : 0
  for_each = var.databases

  name                = "${azurerm_mssql_database.main[each.key].name}-cpu"
  resource_group_name = data.azurerm_resource_group.main[0].name
  scopes              = [azurerm_mssql_database.main[each.key].id]

  window_size = var.alert_window_size
  frequency   = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_cpu_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_metric_alert" "storage" {
  # count = var.azure_enable_monitoring ? 1 : 0
  for_each = var.databases

  name                = "${azurerm_mssql_database.main[each.key].name}-storage"
  resource_group_name = data.azurerm_resource_group.main[0].name

  scopes = [
    azurerm_mssql_database.main[each.key].id
  ]

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_storage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_account" "backup" {
  count = local.azure_enable_backup_storage ? 1 : 0

  name                             = "${var.azure_resource_prefix}${var.service_short}dbbkp${var.config_short}sa"
  location                         = data.azurerm_resource_group.main[0].location
  resource_group_name              = data.azurerm_resource_group.main[0].name
  account_tier                     = "Standard"
  account_replication_type         = "GRS"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  public_network_access_enabled    = var.azure_backup_storage_public_network_access_enabled

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

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

  name                  = "sql-database-backup"
  storage_account_id    = azurerm_storage_account.backup[0].id
  container_access_type = "private"
}

resource "azurerm_storage_container_immutability_policy" "backup" {
  count = local.azure_enable_backup_storage && var.environment == "production" ? 1 : 0

  storage_container_resource_manager_id = "${azurerm_storage_container.backup[0].storage_account_id}/blobServices/default/containers/sql-database-backup"
  immutability_period_in_days           = 14
  protected_append_writes_all_enabled   = false
  protected_append_writes_enabled       = false

  locked = true
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
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }
        dynamic "volume" {
          for_each = length(local.extra_database_names) > 0 ? [1] : []

          content {
            name = "postgres-init"

            config_map {
              name = kubernetes_config_map.postgres_init[0].metadata[0].name
            }
          }
        }
        container {
          name  = local.kubernetes_name
          image = local.server_docker_image
          # args  = try(slice(local.command, 1, length(local.command)), null)
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
          dynamic "env" {
            for_each = var.create_database ? [1] : []
            content {
              name  = "POSTGRES_DB"
              value = local.database_name
            }
          }
          dynamic "volume_mount" {
            for_each = length(local.extra_database_names) > 0 ? [1] : []

            content {
              name       = "postgres-init"
              mount_path = "/docker-entrypoint-initdb.d"
              read_only  = true
            }
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
