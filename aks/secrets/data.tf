locals {
  name_prefix = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}"
  name_suffix = var.key_vault_short != null ? "-${var.key_vault_short}" : ""
}

data "azurerm_resource_group" "main" {
  name = "${local.name_prefix}-rg"
}

data "azurerm_key_vault" "main" {
  name                = "${local.name_prefix}${local.name_suffix}-kv"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_key_vault_secrets" "main" {
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "main" {
  for_each     = toset(data.azurerm_key_vault_secrets.main.names)
  key_vault_id = data.azurerm_key_vault.main.id
  name         = each.key
}
