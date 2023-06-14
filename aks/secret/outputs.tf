output "value" {
  value = var.is_yaml ? yamldecode(data.azurerm_key_vault_secret.main.value) : data.azurerm_key_vault_secret.main.value
}
