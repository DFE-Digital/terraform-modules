output "host" {
  value     = azurerm_mssql_server.main[0].fully_qualified_domain_name
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
