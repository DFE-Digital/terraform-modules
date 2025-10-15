# AKS Postgres

Terraform code for deploying a PostgreSQL instance.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

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
  azure_storage_tier = "P4"  # Optional: Override default Premium storage tier (P4-P80)
}
```

### Enabling logical replication for airbyte

If configuring airbyte for a service, then add
```
use_airbyte = true
azure_enable_monitoring = true # recommended if not enabled
```
which will enable logical replication for the database server.
This will cause the database server to restart several times.

### Enabling postgis for a service

If enabling postgis for a service, then add
```
server_postgis_version = "14-3.2"
```
postgis will automatically be added to azure_extensions if needed.
The server_docker_image will automatically be updated with the postgis version stated, and the image will be pulled from the cached tsc ghcr.io package repo.

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

### `azure_server_id`

ID of the database server in terraform. It can be used to create more databases in the same server (only available when using Azure postgres).
