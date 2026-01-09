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
  value       = local.source_id
  sensitive   = true
}
# need to allow for source_postgres_container[0]

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
