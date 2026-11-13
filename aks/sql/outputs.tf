output "host" {
  value     = azurerm_mssql_server.main.fully_qualified_domain_name
  sensitive = true
}

output "url" {
  value     = "sqlserver://${local.database_username}:${urlencode(local.database_password)}@${local.host}:1433/${local.database_name}"
  sensitive = true
}

output "dotnet_connection_string" {
  value = join("", [
    "Server=tcp:${local.host},1433;",
    "Initial Catalog=${local.database_name};",
    "Persist Security Info=False;",
    "User ID=${local.database_username};",
    "Password=${local.database_password};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])

  sensitive = true
}

output "azure_backup_storage_account_name" {
  value = local.azure_enable_backup_storage ? azurerm_storage_account.backup[0].name : null
}

output "azure_backup_storage_container_name" {
  value = local.azure_enable_backup_storage ? azurerm_storage_container.backup[0].name : null
}
