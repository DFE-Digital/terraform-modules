variable "name" {
  type        = string
  description = "Name of the cluster"
}

locals {
  configuration_maps = {
    cluster1 = {
      resource_group_name = "s189d01-tsc-dv-rg"
      resource_prefix     = "s189d01-tsc-cluster1"
      dns_zone_prefix     = "cluster1.development"
      cpu_min             = 0.1
    }

    cluster2 = {
      resource_group_name = "s189d01-tsc-dv-rg"
      resource_prefix     = "s189d01-tsc-cluster2"
      dns_zone_prefix     = "cluster2.development"
      cpu_min             = 0.1
    }

    cluster3 = {
      resource_group_name = "s189d01-tsc-dv-rg"
      resource_prefix     = "s189d01-tsc-cluster3"
      dns_zone_prefix     = "cluster3.development"
      cpu_min             = 0.1
    }

    cluster4 = {
      resource_group_name = "s189d01-tsc-dv-rg"
      resource_prefix     = "s189d01-tsc-cluster4"
      dns_zone_prefix     = "cluster4.development"
      cpu_min             = 0.1
    }

    cluster5 = {
      resource_group_name = "s189d01-tsc-dv-rg"
      resource_prefix     = "s189d01-tsc-cluster5"
      dns_zone_prefix     = "cluster5.development"
      cpu_min             = 0.1
    }

    cluster6 = {
      resource_group_name = "s189d01-tsc-dv-rg"
      resource_prefix     = "s189d01-tsc-cluster6"
      dns_zone_prefix     = "cluster6.development"
      cpu_min             = 0.1
    }

    test = {
      resource_group_name = "s189t01-tsc-ts-rg"
      resource_prefix     = "s189t01-tsc-test"
      dns_zone_prefix     = "test"
      cpu_min             = 0.05
    }

    platform-test = {
      resource_group_name = "s189t01-tsc-pt-rg"
      resource_prefix     = "s189t01-tsc-platform-test"
      dns_zone_prefix     = "platform-test"
      cpu_min             = 0.1
    }

    production = {
      resource_group_name = "s189p01-tsc-pd-rg"
      resource_prefix     = "s189p01-tsc-production"
      dns_zone_prefix     = null
      cpu_min             = 0.5
    }
  }

  configuration_map                 = local.configuration_maps[var.name]
  dns_zone_prefix_with_optional_dot = local.configuration_map.dns_zone_prefix == null ? "" : "${local.configuration_map.dns_zone_prefix}."

  kubelogin_args_map = {
    spn = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      data.azurerm_client_config.current.tenant_id,
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630" # See https://azure.github.io/kubelogin/concepts/aks.html
    ],
    azurecli = [
      "get-token",
      "--login",
      "azurecli",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630"
    ]
  }

  azure_RBAC_enabled = length(data.azurerm_kubernetes_cluster.main.azure_active_directory_role_based_access_control) > 0

  spn_authentication = contains(keys(data.environment_variables.github_actions.items), "GITHUB_ACTIONS")
}
