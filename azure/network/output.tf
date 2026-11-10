output "postgres_subnet" {
  description = "A subnet dedicated to PostgreSQL databases"
  value = var.enable_postgres ? azurerm_subnet.postgres[0].id : null
}

output "sql_subnet" {
  description = "A subnet dedicated to SQL databases"
  value = var.enable_sql ? azurerm_subnet.sql[0].id : null
}

output "redis_subnet" {
  description = "A subnet dedicated to Redis databases"
  value = var.enable_redis ? azurerm_subnet.redis[0].id : null
}

output "apps_subnet" {
  description = "A subnet dedicated to web and function apps"
  value = var.enable_apps ? azurerm_subnet.apps[0].id : null
}

output "storage_subnet" {
  description = "A subnet dedicated to storage accounts"
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

output "sql_privdns_name" {
  description = "Connection URLs for additional SQL databases"
  value = var.enable_sql ? azurerm_private_dns_zone.sql_logical_server[0].name : null
}

output "sql_privdns_id" {
  description = "Connection URLs for additional SQL databases"
  value = var.enable_sql ? azurerm_private_dns_zone.sql_logical_server[0].id : null
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

output "generic_private_endpoints_subnet_id" {
  description = "The ID of the generic private endpoints subnet"
  value = var.enable_generic_private_endpoints ? azurerm_subnet.private_endpoints[0].id : null
}

output "generic_private_endpoints_privdns_name" {
  description = "The names of the private DNS zones for generic private endpoints"

  value = var.enable_generic_private_endpoints ? {
    for key, zone in azurerm_private_dns_zone.generic :
    key => zone.name
  } : {}
}

output "generic_private_endpoints_privdns_id" {
  description = "The IDs of the private DNS zones for generic private endpoints"
  
  value = var.enable_generic_private_endpoints ? {
    for key, zone in azurerm_private_dns_zone.generic :
    key => zone.id
  } : {}
}