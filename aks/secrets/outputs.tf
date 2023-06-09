output "key_vault_name" {
  value = data.azurerm_key_vault.main.name
}

output "application" {
  value     = yamldecode(data.azurerm_key_vault_secret.application.value)
  sensitive = true
}

output "infrastructure" {
  value     = yamldecode(data.azurerm_key_vault_secret.infrastructure.value)
  sensitive = true
}
