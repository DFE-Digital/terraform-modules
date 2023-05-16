output "kubernetes_config_map_name" {
  value = kubernetes_config_map.main.metadata.0.name
}

output "kubernetes_secret_name" {
  value = kubernetes_secret.main.metadata.0.name
}
