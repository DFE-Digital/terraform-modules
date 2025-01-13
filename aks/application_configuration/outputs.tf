output "kubernetes_config_map_name" {
  description = "Name of the kubernetes configmap containing the non-secret environment variables"
  value       = kubernetes_config_map.main.metadata.0.name
}

output "kubernetes_secret_name" {
  description = "Name of the kubernetes secret containing the secret environment variables"
  value       = kubernetes_secret.main.metadata.0.name
}

output "variables_map" {
  description = "Map of all non-secret environment variables"
  value       = local.config_map_data
}

output "secrets_map" {
  description = "Map of all secret environment variables"
  value       = local.secret_data
  sensitive   = true
}

output "map" {
  description = "Map of all environment variables, including secret and non-secret."
  value       = local.secret_data
  sensitive   = true
}
