# Azure Network

Terraform code for deploying an Azure Vnet with associated components including subnets and private DNS, with the recommended best practices and security settings.

**Note: This module creates resources in the UK South region.**

## Terraform documentation

For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).


## Usage

A module call to create a **public** vnet is the default and would look like this:-
```terraform
module "network" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//azure/network?ref=stable"

  environment                   = var.environment
  azure_resource_prefix         = var.azure_resource_prefix
  service_short                 = var.service_short
  config_short                  = var.config_short
  config                        = var.config
  service_name                  = var.service_name
  enable_storage                = true
  enable_redis                  = false # default
  enable_postgres               = false # default
}
```

Default settings will ony create a vnet, with no further components:-

To enable subnets and required private DNS for a particular service that require a vnet (e.g. using private endpoints), then set the enable variable to true

```
  enable_storage   = true # for Azure storage account
  enable_redis     = true # for Azure managed Redis
  enable_postgres  = true # for Azure Postgresql
```

Default network CIDR ranges will be used for the vnet and subnets.
These can be overridden if required

```
  vnet_address    = ["168.0.0.0/12"]  # default = ["10.0.0.0/12"]
  postgres_subnet = ["10.3.0.0/18"]   # default = ["10.2.0.0/18"]
  redis_subnet    = ["10.3.64.0/18"]  # default = ["10.2.64.0/18"]
  storage_subnet  = ["10.3.128.0/18"] # default = ["10.2.128.0/18"]
```

## Security features

This module implements the following security features by default:
