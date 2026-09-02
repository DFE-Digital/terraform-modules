# Azure Managed Redis

Terraform code for deploying an Azure Managed Redis instance.

## Terraform documentation

For the list of requirements, inputs, outputs and resources, check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "redis_managed" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//azure/redis_managed?ref=stable"

  name = "cache"

  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = "apply-for-qts"
  service_short         = "afqts"
  config_short          = "dv"

  azure_managed_redis_sku = var.redis_managed_cache_sku_name

  subnet_id    = module.network.redis_subnet
  dnszone_name = module.network.redis_privdns_name
  dnszone_id   = module.network.redis_privdns_id
}
```

### Monitoring

If `azure_enable_monitoring` is `true`, it’s expected that the following resources already exist:

- A resource group named `${azure_resource_prefix}-${service_short}-mn-rg` (where `mn` stands for monitoring and `rg` stands for resource group).
- A monitor action group named `${azure_resource_prefix}-${service_name}` within the above resource group.

## Outputs

### `url`

The URL of the Azure Managed Redis instance.

### `connection_string`

A connection string that's compatible with .NET applications to the Azure Managed Redis instance.
