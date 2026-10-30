# Azure SQL

Terraform code for deploying an SQL Logical Server.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "sql" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//azure/sql?ref=stable"

  name = "database-name-suffix"

  azure_resource_prefix = var.azure_resource_prefix
  service_name          = "apply-for-qts"
  service_short         = "afqts"
  config_short          = "dv"

  extra_databases       = var.extra_databases # Optional: Specify additional databases to deploy alongside primary

  cluster_configuration_map = module.aks_cluster_data.configuration_map
}
```

### Implementing multiple databases on a single PostgreSQL server

The `extra_databases` input accepts short database identifiers. The module prefixes each value with the standard database naming convention:

`${service_short}_${environment}_${newdbname}`

For example:

```
extra_databases = [
  "audit",
  "reporting"
]
```

produces:

```
service_env_audit
service_env_reporting
```

**Consuming generated outputs**

Note that consuming the outputs is still achieved using the shortened database name you provided upon creation.

For example, to retrieve the PostgreSQL URL for the generated `service_env_audit` database:

```
module.postgres.extra_database_urls["audit"]
```

To retrieve the .NET connection string for the generated `service_env_reporting` database:

```
module.postgres.extra_dotnet_connection_strings["reporting"]
```

**Review app support**

When `use_azure = false`, additional databases are generated using PostgreSQL initialisation scripts mounted into `/docker-entrypoint-initdb.d`. This ensures review-app PostgreSQL containers create the same additional databases as Azure Flexible Server deployments

Note that PostgreSQL initialisation scripts are only executed when a database container is initialised for the first time.

### Enabling logical replication for airbyte

If configuring airbyte for a service, then add
```
use_airbyte = true
azure_enable_monitoring = true # recommended if not enabled
```
which will enable logical replication for the database server.
This will cause the database server to restart several times.

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

The name of the primary database.

### `extra_databases`

List of names of any additional databases deployed alongside the primary.

### `url`

The URL used to connect to the PostgreSQL instance.

### `extra_database_urls`

A map of additional database names to PostgreSQL connection URLs.

### `dotnet_connection_string`

A connection string that's compatible with .NET applications to the PostgreSQL instance.

### `extra_dotnet_connection_strings`

A map of additional database names to .NET connection strings.

### `azure_backup_storage_account_name`

The name of the storage account that can be used to store backups.

### `azure_backup_storage_container_name`

The name of the storage container that can be used to store backups.

### `azure_server_id`

ID of the database server in terraform. It can be used to create more databases in the same server (only available when using Azure postgres).
