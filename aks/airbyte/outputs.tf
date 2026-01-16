output "password" {
  value     = local.replication_password
  sensitive = true
}

output "google_cloud_credentials" {
  description = "Credentials for Google workload identity federation"
  value       = local.gcp_credentials
  sensitive   = true
}

output "airbyte_source_id" {
  description = "id of the airbyte postgres source"
  value       = airbyte_source_postgres.source_postgres.source_id
  sensitive   = true
}

output "airbyte_destination_id" {
  description = "id of the airbyte gcp source"
  value       = airbyte_destination_bigquery.destination_bigquery.destination_id
  sensitive   = true
}

output "airbyte_connection_id" {
  description = "id of the airbyte connection"
  value       = airbyte_connection.connection.connection_id
  sensitive   = true
}
