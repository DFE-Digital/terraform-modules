data "azurerm_key_vault" "main" {
  name                = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-kv"
  resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

data "azurerm_key_vault_secret" "application" {
  key_vault_id = data.azurerm_key_vault.main.id
  name         = var.application_key_vault_secret_name
}

data "azurerm_key_vault_secret" "infrastructure" {
  key_vault_id = data.azurerm_key_vault.main.id
  name         = var.infrastructure_key_vault_secret_name
}
