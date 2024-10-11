variable "azure_resource_prefix" {
  type        = string
  description = "Prefix of Azure resources for the service. Required"
}
variable "cluster" {
  type        = string
  description = "AKS cluster name e.g. test, production... Required"
}
variable "namespace" {
  type        = string
  description = "AKS Namespace where the service is deployed to. Required"
}
variable "service_short" {
  type        = string
  description = "Short name for the service e.g. att, aytq... Required"
}
variable "environment" {
  type        = string
  description = "Service environment name e.g. production, test, pr-1234... Required"
}

variable "gcp_dataset" {
  type        = string
  description = "Name of an existing dataset. Optional: if not provided, create a new dataset"
  default     = null
}
variable "gcp_keyring" {
  type        = string
  description = "Name of an existing keyring. Required"
}
variable "gcp_key" {
  type        = string
  description = "Name of an existing customer-managed encryption key (CMEK). Required"
}
variable "gcp_project_id" {
  type        = string
  description = "ID of the Google cloud project e.g. 'rugged-abacus-218110', 'apply-for-qts-in-england'... Required"
}
variable "gcp_project_number" {
  type        = number
  description = "Google cloud project number. Required"
}
variable "gcp_taxonomy_id" {
  type        = number
  description = "Policy tags taxonomy ID. Required"
}
variable "gcp_policy_tag_id" {
  type        = number
  description = "Policy tag ID. Required"
}
variable "gcp_table_deletion_protection" {
  type        = bool
  description = "Prevents deletion of the event table. Default: true"
  default     = true
  nullable    = true
}

locals {
  # Global constants
  gcp_region           = "europe-west2"
  gcp_table_name       = "events"
  gcp_workload_id_pool = "azure-cip-identity-pool"

  gcp_dataset_name           = var.gcp_dataset == null ? replace("${var.service_short}_events_${var.environment}_spike", "-", "_") : var.gcp_dataset
  gcp_principal              = "principal://iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${local.gcp_workload_id_pool}"
  gcp_principal_with_subject = "${local.gcp_principal}/subject/${data.azurerm_user_assigned_identity.gcp_wif.principal_id}"

  gcp_credentials_map = {
    universe_domain    = "googleapis.com"
    type               = "external_account"
    audience           = "//iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/azure-cip-identity-pool/providers/azure-cip-oidc-provider"
    subject_token_type = "urn:ietf:params:oauth:token-type:jwt"
    token_url          = "https://sts.googleapis.com/v1/token"
    credential_source = {
      url = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/token"
    }
    service_account_impersonation_url = "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.appender.email}:generateAccessToken"
    service_account_impersonation = {
      token_lifetime_seconds = 3600
    }
  }
  gcp_credentials     = jsonencode(local.gcp_credentials_map)
  gcp_policy_tag_name = "projects/${var.gcp_project_id}/locations/${local.gcp_region}/taxonomies/${var.gcp_taxonomy_id}/policyTags/${var.gcp_policy_tag_id}"
}
