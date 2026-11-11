output "id" {
  value       = azurerm_user_assigned_identity.app_service_identity.id
  description = "The ID of the user assigned identity"
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.app_service_identity.principal_id
  description = "The principal ID of the user assigned identity"
}

output "name" {
  value       = azurerm_user_assigned_identity.app_service_identity.name
  description = "The name of the user assigned identity"
}
