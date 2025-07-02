
output "password" {
  value     = local.replication_password
  sensitive = true
}

output "source_id" {
  value = airbyte_source_postgres.source_postgres[0].source_id
}

output "destination_id" {
  value = airbyte_destination_bigquery.destination_bigquery[0].destination_id
}

output "connection_id" {
  value = airbyte_connection.connection[0].connection_id
}
