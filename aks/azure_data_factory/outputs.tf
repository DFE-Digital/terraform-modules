output "data_factory_id" {
  value = azurerm_data_factory.main.id
}

output "data_factory_name" {
  value = azurerm_data_factory.main.name
}

output "data_factory_identity_tenant_id" {
  value = azurerm_data_factory.main.identity.0.tenant_id
}

output "data_factory_identity_principal_id" {
  value = azurerm_data_factory.main.identity.0.principal_id
}

output "standard_storage_account_id" {
  value = var.create_standard_storage_account ? azurerm_storage_account.standard[0].id : null
}

output "standard_storage_account_name" {
  value = var.create_standard_storage_account ? azurerm_storage_account.standard[0].name : null
}

output "sql_private_endpoint_names" {
  description = "SQL Server managed private endpoints created by the module."
  value       = sort(keys(local.sql_private_endpoints))
}

output "postgresql_private_endpoint_names" {
  description = "PostgreSQL managed private endpoints created by the module."
  value       = sort(keys(local.postgresql_private_endpoints))
}
