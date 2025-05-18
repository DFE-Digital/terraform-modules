output "id" {
  description = "The ID of the Storage Account"
  value       = var.create_storage_account ? azurerm_storage_account.main[0].id : null
}

output "name" {
  description = "The name of the Storage Account"
  value       = var.create_storage_account ? azurerm_storage_account.main[0].name : null
}

output "primary_access_key" {
  description = "The primary access key for the Storage Account"
  value       = var.create_storage_account ? azurerm_storage_account.main[0].primary_access_key : null
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the Storage Account"
  value       = var.create_storage_account ? azurerm_storage_account.main[0].primary_connection_string : null
  sensitive   = true
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = var.create_storage_account ? azurerm_storage_account.main[0].primary_blob_endpoint : null
}

output "containers" {
  description = "A map of container names to their properties"
  value = var.create_storage_account ? {
    for name, container in azurerm_storage_container.containers : name => {
      id = container.id
    }
  } : {}
}
