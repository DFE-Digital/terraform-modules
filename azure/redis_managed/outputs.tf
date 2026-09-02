output "url" {
  value     = "rediss://:${azurerm_managed_redis.main.default_database[0].primary_access_key}@${azurerm_managed_redis.main.hostname}:10000/0"
  sensitive = true
}

output "connection_string" {
  value     = "${azurerm_managed_redis.main.hostname}:10000,password=${azurerm_managed_redis.main.default_database[0].primary_access_key},ssl=true"
  sensitive = true
}
