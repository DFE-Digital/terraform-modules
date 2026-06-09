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

output "primary_queue_endpoint" {
  description = "The primary queue endpoint URL"
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "containers" {
  description = "A map of container names to their properties"
  value = {
    for name, container in azurerm_storage_container.containers : name => {
      id = container.id
    }
  }
}

output "storage_private_blob_fqdn" {
  value = var.use_private_storage ? "${azurerm_storage_account.main.name}.privatelink.blob.core.windows.net" : null
}

output "storage_private_queue_fqdn" {
  value = var.use_private_storage && length(var.queues) > 0 ? "${azurerm_storage_account.main.name}.privatelink.queue.core.windows.net" : null
}

output "queues" {
  description = "A map of queue names to their properties"
  value = {
    for name, queue in azurerm_storage_queue.queues : name => {
      id = queue.id
    }
  }
}
