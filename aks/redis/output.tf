output "url" {
  value     = var.use_azure ? "rediss://:${azurerm_redis_cache.main[0].primary_access_key}@${azurerm_redis_cache.main[0].hostname}:${azurerm_redis_cache.main[0].ssl_port}/0" : "redis://${local.kubernetes_name}:6379/0"
  sensitive = true
}
