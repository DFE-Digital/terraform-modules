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

output "url" {
  value     = "postgres://${urlencode(local.database_username)}:${urlencode(local.database_password)}@${local.host}:${local.port}/${local.database_name}"
  sensitive = true
}
