locals {
  # common variables
  action_group_id                = data.azurerm_monitor_action_group.main[0].id
  monitoring_resource_group_name = data.azurerm_resource_group.monitoring[0].name
  deployment_resource_group_name  = data.azurerm_resource_group.rg[0].name
  alert_frequency_map = {
    PT5M  = "PT1M"
    PT15M = "PT1M"
    PT30M = "PT1M"
    PT1H  = "PT1M"
    PT6H  = "PT5M"
    PT12H = "PT5M"
  }
  alert_frequency = local.alert_frequency_map[var.alert_window_size]

  # app variables
  name_suffix = var.app_name != null ? "-${var.app_name}" : ""
  app_name    = "${var.service_name}-${var.environment}${local.name_suffix}"

  # db variables
  db_name   = data.azurerm_postgresql_flexible_server.db[0].name
  db_scopes = [data.azurerm_postgresql_flexible_server.db[0].id]

  # redis variables
  redis_cache_name   = data.azurerm_redis_cache.redis_cache[0].name
  redis_cache_scopes = [data.azurerm_redis_cache.redis_cache[0].id]
}