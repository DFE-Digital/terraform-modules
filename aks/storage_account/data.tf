
data "azurerm_resource_group" "main" {
  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

data "azurerm_virtual_network" "priv" {
  count               = var.use_private_storage ? 1 : 0
  name                = "${var.cluster_configuration_map.resource_prefix}-vnet"
  resource_group_name = var.cluster_configuration_map.resource_group_name
}

data "azurerm_subnet" "priv" {
  count                = var.use_private_storage ? 1 : 0
  name                 = "private-storage-snet"
  virtual_network_name = "${var.cluster_configuration_map.resource_prefix}-vnet"
  resource_group_name  = var.cluster_configuration_map.resource_group_name
}

data "azurerm_private_dns_zone" "priv" {
  count               = var.use_private_storage ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "${var.cluster_configuration_map.resource_prefix}-bs-rg"
}