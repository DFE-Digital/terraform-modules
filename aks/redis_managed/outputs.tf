output "url" {
  value     = var.use_azure ? "rediss://:${azurerm_managed_redis.main[0].default_database[0].primary_access_key}@${azurerm_managed_redis.main[0].hostname}:10000/0" : "redis://${kubernetes_service.main[0].metadata[0].name}:6379/0"
  sensitive = true
}


output "connection_string" {
  value     = var.use_azure ? "${azurerm_managed_redis.main[0].hostname}:10000,password=${azurerm_managed_redis.main[0].default_database[0].primary_access_key},ssl=true" : "${kubernetes_service.main[0].metadata[0].name}:6379"
  sensitive = true
}
