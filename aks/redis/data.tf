data "azurerm_resource_group" "main" {
  count = var.use_azure ? 1 : 0

  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

data "azurerm_subnet" "main" {
  count = var.use_azure ? 1 : 0

  name                 = "redis-snet"
  virtual_network_name = "${var.cluster_configuration_map.resource_prefix}-vnet"
  resource_group_name  = var.cluster_configuration_map.resource_group_name
}

data "azurerm_private_dns_zone" "main" {
  count = var.use_azure ? 1 : 0

  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = "${var.cluster_configuration_map.resource_prefix}-bs-rg"
}

data "azurerm_monitor_action_group" "main" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${var.azure_resource_prefix}-${var.service_name}"
  resource_group_name = data.azurerm_resource_group.main[0].name
}
