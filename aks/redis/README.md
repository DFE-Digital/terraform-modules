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
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.aks_cluster_data.configuration_map

  use_azure = var.deploy_azure_backing_services
}
```

## Outputs

### `url`

The URL of the Redis instance.
