# application alert

resource "azurerm_monitor_metric_alert" "container_restarts" {
  count = var.azure_enable_app_monitoring ? 1 : 0

  name                = "${local.app_name}-container-restarts"
  resource_group_name = local.monitoring_resource_group_name
  scopes              = [var.kubernetes_cluster_id]
  description         = "Action will be triggered when container restarts is greater than 0"
  window_size         = "PT30M"

  criteria {
    metric_namespace = "Insights.container/pods"
    metric_name      = "restartingContainerCount"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "controllerName"
      operator = "StartsWith"
      values   = ["${local.app_name}"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main.id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# postgres alerts
resource "azurerm_monitor_metric_alert" "db_memory" {
  count = var.azure_enable_db_monitoring ? 1 : 0

  name                = "${var.db_name}-memory"
  resource_group_name = local.deployment_resource_group_name
  scopes              = [data.azurerm_postgresql_flexible_server.db[0].id]
  description         = "Action will be triggered when memory use is greater than 75%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_db_memory_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main.id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "db_cpu" {
  count = var.azure_enable_db_monitoring ? 1 : 0

  name                = "${local.db_name}-cpu"
  resource_group_name = local.deployment_resource_group_name
  scopes              = local.db_scopes
  description         = "Action will be triggered when cpu use is greater than ${var.azure_db_cpu_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_db_cpu_threshold
  }

  action {
    action_group_id = local.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "db_storage" {
  count = var.azure_enable_db_monitoring ? 1 : 0

  name                = "${local.db_name}-storage"
  resource_group_name = local.deployment_resource_group_name
  scopes              = local.db_scopes
  description         = "Action will be triggered when storage use is greater than ${var.azure_db_storage_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_db_storage_threshold
  }

  action {
    action_group_id = local.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# redis alerts
resource "azurerm_monitor_metric_alert" "redis_memory" {
  count = var.azure_enable_redis_monitoring ? 1 : 0

  name                = "${local.redis_cache_name}-memory"
  resource_group_name = local.deployment_resource_group_name
  scopes              = local.redis_cache_scopes
  description         = "Action will be triggered when memory use is greater than ${var.azure_redis_memory_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "allusedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_redis_memory_threshold
  }

  action {
    action_group_id = local.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
