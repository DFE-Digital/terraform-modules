resource "google_service_account" "appender" {
  account_id   = "appender-${var.service_short}-${var.environment}"
  display_name = "Service Account appender to ${var.service_short} in ${var.environment} environment"
}

resource "google_service_account_iam_binding" "appender" {
  service_account_id = google_service_account.appender.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    local.gcp_principal_with_subject
  ]
}

# # Create key ring if it doesn't exist
# resource "google_kms_key_ring" "bigquery" {
#   count = var.gcp_keyring == null ? 1 : 0

#   name     = local.gcp_key_ring
#   location = local.gcp_region
# }

# # Create key if it doesn't exist
# resource "google_kms_crypto_key" "bigquery" {
#   count = var.gcp_key == null ? 1 : 0

#   name     = local.gcp_key
#   key_ring = google_kms_key_ring.bigquery[0].id
# }

# Add permission if key didn't exist
data "google_bigquery_default_service_account" "main" {}

data "google_kms_key_ring" "main" {
  name     = var.gcp_keyring
  location = local.gcp_region
}

data "google_kms_crypto_key" "main" {
  name     = var.gcp_key
  key_ring = data.google_kms_key_ring.main.id
}

resource "google_kms_crypto_key_iam_member" "bigquery" {
  crypto_key_id = data.google_kms_crypto_key.main.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_bigquery_default_service_account.main.email}"
}

# Create dataset if it doesn't exist
resource "google_bigquery_dataset" "main" {
  count = var.gcp_dataset == null ? 1 : 0

  dataset_id = local.gcp_dataset_name
  location   = local.gcp_region
  default_encryption_configuration {
    kms_key_name = data.google_kms_crypto_key.main.id
  }
}

# Add service account permission to dataset, wether we create it or it already exists
resource "google_bigquery_dataset_iam_binding" "appender" {
  dataset_id = var.gcp_dataset == null ? google_bigquery_dataset.main[0].dataset_id : var.gcp_dataset
  role       = "projects/${var.gcp_project_id}/roles/bigquery_appender_custom"

  members = [
    "serviceAccount:${google_service_account.appender.email}",
  ]
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
    kms_key_name = data.google_kms_crypto_key.main.id
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
