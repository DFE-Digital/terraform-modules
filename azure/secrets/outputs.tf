output "map" {
  value     = { for key, secret in data.azurerm_key_vault_secret.main : key => secret.value }
  sensitive = true
}

output "key_vault_id" {
  value       = data.azurerm_key_vault.main.id
  description = "ID of the Key Vault"
}
