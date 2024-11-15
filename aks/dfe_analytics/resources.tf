resource "google_service_account" "appender" {
  account_id   = "app-wif-${var.service_short}-${var.environment}"
  display_name = "Service Account appender to ${var.service_short} in ${var.environment} environment"
  description  = "Configured with workflow identity federation from Azure"
}

resource "google_service_account_iam_binding" "appender" {
  service_account_id = google_service_account.appender.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    local.gcp_principal_with_subject
  ]
}

data "google_kms_key_ring" "main" {
  count = var.gcp_keyring != null ? 1 : 0

  name     = var.gcp_keyring
  location = local.gcp_region
}

data "google_kms_crypto_key" "main" {
  count = var.gcp_key != null ? 1 : 0

  name     = var.gcp_key
  key_ring = data.google_kms_key_ring.main[0].id
}

# Create dataset if it doesn't exist
resource "google_bigquery_dataset" "main" {
  count = var.gcp_dataset == null ? 1 : 0

  dataset_id = local.gcp_dataset_name
  location   = local.gcp_region
  default_encryption_configuration {
    kms_key_name = data.google_kms_crypto_key.main[0].id
  }
}

# Add service account permission to dataset, wether we create it or it already exists
resource "google_bigquery_dataset_iam_member" "appender" {
  dataset_id = var.gcp_dataset == null ? google_bigquery_dataset.main[0].dataset_id : var.gcp_dataset
  role       = "projects/${data.google_project.main.project_id}/roles/bigquery_appender_custom"
  member     = "serviceAccount:${google_service_account.appender.email}"
}

# Create table if dataset doesn't exist
resource "google_bigquery_table" "events" {
  count = var.gcp_dataset == null ? 1 : 0

  dataset_id               = google_bigquery_dataset.main[0].dataset_id
  table_id                 = local.gcp_table_name
  description              = "Events streamed into the BigQuery from the application"
  clustering               = ["event_type"]
  deletion_protection      = var.gcp_table_deletion_protection
  require_partition_filter = false

  encryption_configuration {
    kms_key_name = data.google_kms_crypto_key.main[0].id
  }

  time_partitioning {
    type  = "DAY"
    field = "occurred_at"
  }

  # https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/create-events-table.sql
  schema = templatefile(
    "${path.module}/files/events.json.tmpl",
    { policy_tag_name = local.gcp_policy_tag_name }
  )
}
