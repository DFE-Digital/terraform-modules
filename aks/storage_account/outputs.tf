output "id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.main.id
}

output "name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.main.name
}

output "primary_access_key" {
  description = "The primary access key for the Storage Account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the Storage Account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "containers" {
  description = "A map of container names to their properties"
  value = var.azurerm_v4 ? {
    for name, container in azurerm_storage_container.containers : name => {
      id = container.id
    }
  } : {
    for name, container in azurerm_storage_container.containers_v4 : name => {
      id = container.id
    }
  }
}
