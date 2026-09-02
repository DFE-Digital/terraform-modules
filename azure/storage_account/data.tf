data "azurerm_resource_group" "main" {
  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}
