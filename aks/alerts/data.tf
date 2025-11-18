data "azurerm_resource_group" "monitoring" {
  name = "${var.azure_resource_prefix}-${var.service_short}-mn-rg"
}

data "azurerm_monitor_action_group" "main" {
  name                = "${var.azure_resource_prefix}-${var.service_name}"
  resource_group_name = data.azurerm_resource_group.monitoring.name
}

data "azurerm_resource_group" "rg" {

  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

data "azurerm_postgresql_flexible_server" "db" {
  count = var.azure_enable_db_monitoring ? 1 : 0

  name                = var.db_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_redis_cache" "redis_cache" {
  count = var.azure_enable_redis_monitoring ? 1 : 0

  name                = var.redis_cache_name
  resource_group_name = data.azurerm_resource_group.rg.name
}