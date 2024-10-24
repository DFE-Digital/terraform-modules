output "bigquery_project_id" {
  description = "ID of the Google cloud project e.g. 'rugged-abacus-218110', 'apply-for-qts-in-england'..."
  value       = data.google_project.main.project_id
}
output "bigquery_table_name" {
  description = "Biquery events table name"
  value       = local.gcp_table_name
}
output "bigquery_dataset" {
  description = "Bigquery dataset name"
  value       = local.gcp_dataset_name
}
output "google_cloud_credentials" {
  description = "Credentials for Google workload identity federation"
  value       = local.gcp_credentials
}
output "variables_map" {
  description = "Map of environment variables required for dfe-analytics. Merge with application configuration secrets."
  value = {
    BIGQUERY_PROJECT_ID      = data.google_project.main.project_id
    BIGQUERY_TABLE_NAME      = local.gcp_table_name
    BIGQUERY_DATASET         = local.gcp_dataset_name
    GOOGLE_CLOUD_CREDENTIALS = local.gcp_credentials
  }
}
