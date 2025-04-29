
variable "cluster" {
  type        = string
  description = "AKS cluster name e.g. test, production... Required"
}
variable "namespace" {
  type        = string
  description = "AKS Namespace where the service is deployed to. Required"
}
variable "gcp_dataset" {
  type        = string
  description = "Name of an existing dataset. Optional: if not provided, create a new dataset"
  default     = null
}
variable "gcp_keyring" {
  type        = string
  description = "Name of an existing keyring. Required when creating the dataset"
  default     = null
}
variable "gcp_key" {
  type        = string
  description = "Name of an existing customer-managed encryption key (CMEK). Required when creating the dataset"
  default     = null
}
variable "gcp_taxonomy_id" {
  type        = number
  description = "Policy tags taxonomy ID. Required when creating the dataset"
  default     = null
}
variable "gcp_policy_tag_id" {
  type        = number
  description = "Policy tag ID. Required when creating the dataset"
  default     = null
}
variable "gcp_table_deletion_protection" {
  type        = bool
  description = "Prevents deletion of the event table. Default: true"
  default     = true
  nullable    = false
}

locals {
  # Global constants
  gcp_region           = "europe-west2"
  gcp_workload_id_pool = "azure-cip-identity-pool"

  gcp_dataset_name           = var.gcp_dataset == null ? replace("${var.service_short}_airbyte_${var.environment}", "-", "_") : var.gcp_dataset
  gcp_principal              = "principal://iam.googleapis.com/projects/${data.google_project.main.number}/locations/global/workloadIdentityPools/${local.gcp_workload_id_pool}"
  gcp_principal_with_subject = "${local.gcp_principal}/subject/${data.azurerm_user_assigned_identity.gcp_wif.principal_id}"

  gcp_credentials_map = {
    universe_domain    = "googleapis.com"
    type               = "external_account"
    audience           = "//iam.googleapis.com/projects/${data.google_project.main.number}/locations/global/workloadIdentityPools/azure-cip-identity-pool/providers/azure-cip-oidc-provider"
    subject_token_type = "urn:ietf:params:oauth:token-type:id_token"
    token_url          = "https://sts.googleapis.com/v1/token"
    credential_source = {
      url = "http://airbyte-token.${var.namespace}.svc.cluster.local:4567/azure_access_token"
    }
    service_account_impersonation_url = "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.appender.email}:generateAccessToken"
    service_account_impersonation = {
      token_lifetime_seconds = 3600
    }
  }
  gcp_credentials     = jsonencode(local.gcp_credentials_map)
  gcp_policy_tag_name = var.gcp_dataset == null ? "projects/${data.google_project.main.project_id}/locations/${local.gcp_region}/taxonomies/${var.gcp_taxonomy_id}/policyTags/${var.gcp_policy_tag_id}" : ""
}
