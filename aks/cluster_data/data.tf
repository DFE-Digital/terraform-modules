data "azurerm_kubernetes_cluster" "main" {
  name                = "${local.configuration_map.resource_prefix}-aks"
  resource_group_name = local.configuration_map.resource_group_name
}

data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    environment = {
      source  = "EppO/environment"
      version = "1.3.5"
    }
  }
}

data "environment_variables" "github_actions" {
  filter = "GITHUB_ACTIONS"
}
