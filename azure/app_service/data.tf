data "azurerm_resource_group" "main" {
  name = "${local.resource_name_prefix}${var.config_short}-rg"
}

data "azurerm_resource_group" "monitoring" {
  count = var.azure_enable_monitoring ? 1 : 0

  name = "${local.resource_name_prefix}mn-rg"
}
