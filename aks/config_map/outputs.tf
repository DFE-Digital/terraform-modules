output "kubernetes_config_map_name" {
  description = "Name of the kubernetes configmap containing the non-secret environment variables"
  value       = kubernetes_config_map.main.metadata.0.name
}

output "config_map" {
  description = "Map of all non-secret environment variables or data"
  value       = try(file(var.config_file_path))
}
