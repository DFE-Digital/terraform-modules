output "map" {
  value = { for key, secret in data.azurerm_key_vault_secret.main : key => secret.value }
}
