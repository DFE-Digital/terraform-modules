locals {
  host = var.use_azure ? azurerm_postgresql_flexible_server.main[0].fqdn : local.kubernetes_name
  port = 5432
}

output "username" {
  value = local.database_username
}

output "password" {
  value     = local.database_password
  sensitive = true
}

output "host" {
  value     = local.host
  sensitive = true
}

output "port" {
  value = local.port
}

output "name" {
  value = local.database_name
}

output "extra_databases" {
  value       = local.extra_database_names
  description = "Names of additional PostgreSQL databases created by the module"
}

output "url" {
  value     = "postgres://${urlencode(local.database_username)}:${urlencode(local.database_password)}@${local.host}:${local.port}/${local.database_name}?sslmode=${var.use_azure ? "require" : "prefer"}"
  sensitive = true
}

output "extra_database_urls" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = {
    for db in var.extra_databases :
    db => "postgres://${urlencode(local.database_username)}:${urlencode(local.database_password)}@${local.host}:${local.port}/${local.database_name}_${db}?sslmode=${var.use_azure ? "require" : "prefer"}"
  }

  sensitive = true
}

output "dotnet_connection_string" {
  value     = "Server=${local.host};Database=${local.database_name};Port=${local.port};User Id=${local.database_username};Password='${local.database_password}';Ssl Mode=${var.use_azure ? "Require" : "Prefer"};Trust Server Certificate=true;GSS Encryption Mode=Disable"
  sensitive = true
}

output "extra_dotnet_connection_strings" {
  description = "Connection strings for additional PostgreSQL databases"

  value = {
    for db in var.extra_databases :
    db => "Server=${local.host};Database=${local.database_name}_${db};Port=${local.port};User Id=${local.database_username};Password='${local.database_password}';Ssl Mode=${var.use_azure ? "Require" : "Prefer"};Trust Server Certificate=true"
  }

  sensitive = true
}

output "azure_backup_storage_account_name" {
  value = local.azure_enable_backup_storage ? azurerm_storage_account.backup[0].name : null
}

output "azure_backup_storage_container_name" {
  value = local.azure_enable_backup_storage ? azurerm_storage_container.backup[0].name : null
}

output "azure_server_id" {
  value = var.use_azure ? azurerm_postgresql_flexible_server.main[0].id : null
}
