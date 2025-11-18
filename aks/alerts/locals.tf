locals {
  # common variables
  action_group_id                = data.azurerm_monitor_action_group.main.id
  monitoring_resource_group_name = data.azurerm_resource_group.monitoring.name
  deployment_resource_group_name  = data.azurerm_resource_group.rg.name
  alert_frequency_map = {
    PT5M  = "PT1M"
    PT15M = "PT1M"
    PT30M = "PT1M"
    PT1H  = "PT1M"
    PT6H  = "PT5M"
    PT12H = "PT5M"
  }
  alert_frequency = local.alert_frequency_map[var.alert_window_size]

  # db variables
  db_name   = var.azure_enable_db_monitoring ? data.azurerm_postgresql_flexible_server.db[0].name: null
  db_scopes = var.azure_enable_db_monitoring ? [data.azurerm_postgresql_flexible_server.db[0].id]: []

  # redis variables
  redis_cache_name   = var.azure_enable_redis_monitoring ? data.azurerm_redis_cache.redis_cache[0].name : null
  redis_cache_scopes = var.azure_enable_redis_monitoring ? [data.azurerm_redis_cache.redis_cache[0].id]: []
}