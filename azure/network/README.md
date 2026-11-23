# Azure Network

Terraform code for deploying an Azure Vnet with associated components including subnets and private DNS, with the recommended best practices and security settings.

**Note: This module creates resources in the UK South region.**

## Terraform documentation

For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).


## Usage

A module call to create a VNet with a storage subnet and associated private DNS zone would look like this:-
```terraform
module "network" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//azure/network?ref=stable"

  environment                   = var.environment
  azure_resource_prefix         = var.azure_resource_prefix
  service_short                 = var.service_short
  config_short                  = var.config_short
  config                        = var.config
  service_name                  = var.service_name
  vnet_address                  = ["10.0.0.0/12"]
  storage_subnet                = ["10.2.128.0/18"]
  enable_storage                = true
  enable_redis                  = false # default
  enable_postgres               = false # default
}
```

To create a subnet and its required private DNS for a particular service (e.g. using private endpoints), set the corresponding `enable_*` variable to true and supply its subnet range.

```
  enable_storage   = true # for Azure storage account
  enable_redis     = true # for Azure managed Redis
  enable_postgres  = true # for Azure Postgresql
```

There are no default network CIDR ranges. Set a range explicitly for each
resource you want to create; a VNet or subnet without a supplied range is not
created. Subnet creation also requires its corresponding `enable_*` setting.

```
  vnet_address    = ["10.0.0.0/12"]
  postgres_subnet = ["10.2.0.0/18"]
  sql_subnet      = ["10.2.192.0/18"]
  redis_subnet    = ["10.2.64.0/18"]
  apps_subnet     = ["10.3.0.0/18"]
  storage_subnet  = ["10.2.128.0/18"]
```

## Security features

This module implements the following security features by default:
