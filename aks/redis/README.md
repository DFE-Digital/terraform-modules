# AKS Redis

Terraform code for deploying a Redis instance.

## Usage

```terraform
module "redis" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=stable"

  name = "cache"

  namespace             = var.namespace
  environment           = "${var.app_environment}${var.app_suffix}"
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = "apply-for-qts"
  service_short         = "afqts"
  config_short          = "dv"

  cluster_configuration_map = module.aks_cluster_data.configuration_map

  use_azure = var.deploy_azure_backing_services
}
```

### Monitoring

If `azure_enable_monitoring` is `true`, it’s expected that the following resources already exist:

- A resource group named `${azure_resource_prefix}-${service_short}-mn-rg` (where `mn` stands for monitoring and `rg` stands for resource group).
- A monitor action group named `${azure_resource_prefix}-${service_name}` within the above resource group.

## Outputs

### `url`

The URL of the Redis instance.
