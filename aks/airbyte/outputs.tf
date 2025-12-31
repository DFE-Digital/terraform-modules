output "password" {
  value     = local.replication_password
  sensitive = true
}

output "google_cloud_credentials" {
  description = "Credentials for Google workload identity federation"
  value       = local.gcp_credentials
  sensitive   = true
}

output "airbyte_connection_id" {
  value = airbyte_connection.connection.connection_id
}
