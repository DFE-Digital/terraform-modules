# AKS Postgres

Terraform code for deploying a PostgreSQL instance.

## Usage

```terraform
module "postgres" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/postgres?ref=stable"

  name = "database"

  namespace             = var.namespace
  environment           = "${var.app_environment}${var.app_suffix}"
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = "apply-for-qts"
  service_short         = "afqts"
  config_short          = "dv"

  cluster_configuration_map = module.aks_cluster_data.configuration_map

  use_azure = var.deploy_azure_backing_services

  azure_extensions = ["UNACCENT"]
}
```

### Monitoring

If `azure_enable_monitoring` is `true`, it’s expected that the following resources already exist:

- A resource group named `${azure_resource_prefix}-${service_short}-mn-rg` (where `mn` stands for monitoring and `rg` stands for resource group).
- A monitor action group named `${azure_resource_prefix}-${service_name}` within the above resource group.

## Outputs

### `username`

The admin username of the PostgreSQL instance.

### `password`

The admin password of the PostgreSQL instance.

### `host`

The hostname of the PostgreSQL instance.

### `port`

The port of the PostgreSQL instance.

### `name`

The name of the database.

### `url`

The URL used to connect to the PostgreSQL instance.

### `dotnet_connection_string`

A connection string that's compatible with .NET applications to the PostgreSQL instance.

### `azure_backup_storage_account_name`

The name of the storage account that can be used to store backups.

### `azure_backup_storage_container_name`

The name of the storage container that can be used to store backups.
