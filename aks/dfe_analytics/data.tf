module "cluster_data" {
  source = "../cluster_data"
  name   = var.cluster
}

data "azurerm_client_config" "current" {}

data "azurerm_user_assigned_identity" "gcp_wif" {
  name                = "${var.azure_resource_prefix}-gcp-wif-${var.cluster}-${var.namespace}-id"
  resource_group_name = module.cluster_data.configuration_map.resource_group_name
}

data "google_project" "main" {}
