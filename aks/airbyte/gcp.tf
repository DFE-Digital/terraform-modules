module "cluster_data" {
  source = "../cluster_data"
  name   = var.cluster
}

data "azurerm_client_config" "current" {}

data "google_project" "main" {}

data "azurerm_user_assigned_identity" "gcp_wif" {
  name                = "${var.azure_resource_prefix}-gcp-wif-${var.cluster}-${var.namespace}-id"
  resource_group_name = module.cluster_data.configuration_map.resource_group_name
}

# # replace with variable and count
# data "google_service_account" "bqappender" {
#   account_id   = var.gcp_bq_sa
# }

resource "google_service_account" "appender" {
  account_id   = "airbyte-wif-${var.service_short}-${var.environment}"
  display_name = "Service Account appender to ${var.service_short} in ${var.environment} environment"
  description  = "Configured with workflow identity federation from Azure"
}

# Allow authentications from the  Workload Identity Pool azure-cip-identity-pool to the Service Account.
resource "google_service_account_iam_binding" "appender" {
  service_account_id = google_service_account.appender.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    local.gcp_principal_with_subject
  ]
}

# we use Direct Workload Identity Federation between Github action workflows from a repository and GCP for setting up Bigquery,
# so there is no service account impersonation

## current ga wif account doesn't have access to do this
## will need to add privileges to run, unless this becomes insecure and would need to add manually
## or maybe this should be added via a binding?
resource "google_project_iam_member" "appender" {
  project = data.google_project.main.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.appender.email}"
}

# added back due to try and fix User does not have permission to get taxonomy
resource "google_project_iam_member" "viewer" {
  project = data.google_project.main.project_id
  role    = "roles/datacatalog.viewer"
  member  = "serviceAccount:${google_service_account.appender.email}"
}

resource "google_project_iam_member" "bqappender" {
  project = data.google_project.main.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${var.gcp_bq_sa}"
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
  delete_contents_on_destroy = true
}

# Create dataset if it doesn't exist
# resource "google_bigquery_dataset" "internal" {
#   count = var.gcp_dataset_internal == null ? 1 : 0

#   dataset_id = "${local.gcp_dataset_name}_internal"
#   location   = local.gcp_region
#   default_encryption_configuration {
#     kms_key_name = data.google_kms_crypto_key.main[0].id
#   }
#   delete_contents_on_destroy = true
# }

# Create a custom role
# at the moment create this manually once per project
# which means 1 role, if we use terraform will have to have multiple roles
#
# resource "google_project_iam_custom_role" "custom_role" {
#   project = data.google_project.main.project_id
#   role_id = "bigquery_appender_airbyte_${var.service_short}_${var.environment}"
#   title = "BigQuery Appender Airbyte"
#   description = "Assigned to service accounts used to append data to Airbyte events tables."
#   permissions = [
#     "roles/bigquery.datasets.get",
#     "roles/bigquery.tables.get",
#     "roles/bigquery.tables.updateData"
#   ]
# }

# Add service account permission to dataset, whether we create it or it already exists

# put back as seeing Permission bigquery.tables.get denied on table rtt_airbyte_pr_5837.trainees on the worker
# resource "google_bigquery_dataset_iam_member" "appender" {
#   dataset_id = var.gcp_dataset == null ? google_bigquery_dataset.main[0].dataset_id : var.gcp_dataset
#   role       = "projects/${data.google_project.main.project_id}/roles/bigquery_appender_airbyte"
#   member     = "serviceAccount:${google_service_account.appender.email}"
# }

resource "google_bigquery_dataset_iam_member" "appender_internal" {
  dataset_id = "airbyte_internal"
  role       = "projects/${data.google_project.main.project_id}/roles/bigquery_appender_airbyte"
  member     = "serviceAccount:${google_service_account.appender.email}"
}

resource "google_bigquery_dataset_iam_member" "owner" {
  dataset_id = var.gcp_dataset == null ? google_bigquery_dataset.main[0].dataset_id : var.gcp_dataset
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${google_service_account.appender.email}"
}

resource "google_bigquery_dataset_iam_member" "bqowner" {
  dataset_id = var.gcp_dataset == null ? google_bigquery_dataset.main[0].dataset_id : var.gcp_dataset
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${var.gcp_bq_sa}"
}

# resource "google_bigquery_dataset_iam_member" "owner_internal" {
#   dataset_id = var.gcp_dataset_internal == null ? google_bigquery_dataset.internal[0].dataset_id : var.gcp_dataset_internal
#   role       = "roles/bigquery.dataOwner"
#   member     = "serviceAccount:${google_service_account.appender.email}"
# }
