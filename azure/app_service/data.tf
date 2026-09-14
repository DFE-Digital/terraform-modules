data "azurerm_resource_group" "main" {
  name = "${local.resource_name_prefix}${var.config_short}-rg"
}
