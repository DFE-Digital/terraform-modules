output "postgres_subnet" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_postgres ? azurerm_subnet.postgres[0].id : null
}

output "redis_subnet" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_redis ? azurerm_subnet.redis[0].id : null
}

output "storage_subnet" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_storage ? azurerm_subnet.storage[0].id : null
}

output "postgres_privdns_name" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_postgres ? azurerm_private_dns_zone.postgres[0].name : null
}

output "postgres_privdns_id" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_postgres ? azurerm_private_dns_zone.postgres[0].id : null
}

output "redis_privdns_name" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_redis ? azurerm_private_dns_zone.redis[0].name : null
}

output "redis_privdns_id" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_redis ? azurerm_private_dns_zone.redis[0].id : null
}

output "storage_privdns_name" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_storage ? azurerm_private_dns_zone.storage[0].name : null
}

output "storage_privdns_id" {
  description = "Connection URLs for additional PostgreSQL databases"

  value = var.enable_storage ? azurerm_private_dns_zone.storage[0].id : null
}
