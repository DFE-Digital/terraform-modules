
data "azurerm_key_vault" "main" {
  count = var.key_vault_name != null ? 1 : 0

  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "sql_connection_strings" {
  for_each = var.key_vault_name != null ? local.sql_connection_string_secrets : {}

  name         = each.value
  key_vault_id = data.azurerm_key_vault.main[0].id
}

data "azurerm_key_vault_secret" "postgresql_connection_strings" {
  for_each = var.key_vault_name != null ? local.postgresql_connection_string_secrets : {}

  name         = each.value
  key_vault_id = data.azurerm_key_vault.main[0].id
}

data "azurerm_key_vault_secret" "storage_connection_strings" {
  for_each = var.key_vault_name != null ? local.storage_connection_string_secrets : {}

  name         = each.value
  key_vault_id = data.azurerm_key_vault.main[0].id
}
