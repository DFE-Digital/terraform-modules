output "url" {
  value     = var.use_azure ? "rediss://:${azurerm_redis_cache.main[0].primary_access_key}@${azurerm_private_endpoint.main[0].private_dns_zone_configs[0].record_sets[0].name}.redis.cache.windows.net:${azurerm_redis_cache.main[0].ssl_port}/0" : "redis://${kubernetes_service.main[0].metadata[0].name}:6379/0"
  sensitive = true
}
