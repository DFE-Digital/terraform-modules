data "azurerm_resource_group" "main" {
  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

resource "azurerm_virtual_network" "vnet" {

  location            = var.location
  name                = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-vnet"
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = var.vnet_address

  lifecycle { ignore_changes = [tags] }
}
