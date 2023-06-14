data "azurerm_key_vault" "main" {
  name                = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-kv"
  resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

data "azurerm_key_vault_secret" "main" {
  key_vault_id = data.azurerm_key_vault.main.id
  name         = var.name
}
