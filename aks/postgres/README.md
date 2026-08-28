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

  extra_databases       = var.extra_databases # Optional: Specify additional databases to deploy alongside primary

  cluster_configuration_map = module.aks_cluster_data.configuration_map

  use_azure = var.deploy_azure_backing_services

  read_replica_count = 2 # Optional: Creates replica-1 and replica-2. Requires use_azure = true

  azure_extensions = ["UNACCENT"]
  azure_storage_tier = "P4"  # Optional: Override default Premium storage tier (P4-P80)
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

### Creating a PostgreSQL read replica

Azure PostgreSQL Flexible Server read replicas can be created by setting:

```
read_replica_count = 2
```

This would create:

```
subscription-svc-env-pg-replica-1
subscription-svc-env-pg-replica-2
```

The module supports between 0 and 5 read replicas.

Each replica maintains a near real-time, read-only copy of the primary PostgreSQL server.

**Consuming generated outputs**

Outputs are returned as maps keyed by replica name.

To retrieve the PostgreSQL connections URLs for all replica servers:

```
module.postgres.read_replica_urls
```

Which returns:

```
{
  "replica-1" = "postgres://..."
  "replica-2" = "postgres://..."
}
```

To retrieve the PostgreSQL connection URL for `replica-1`:

```
module.postgres.read_replica_urls["replica-1"]
```

To retrieve the .NET connection string for `replica-2`:

```
module.postgres.read_replica_dotnet_connection_strings["replica-2"]
```

**Additional databases**

Read replicas replicate the entire PostgreSQL server, including any databases created using the `extra_databases` input.

For example:

```
extra_databases = [
  "audit",
  "reporting"
]
```

creates:

```
service_env_audit
service_env_reporting
```

The corresponding read replica URLs can be accessed using both the replica name and the shortened database name:

```
module.postgres.read_replica_extra_database_urls["replica-1"]["audit"]
```

The corresponding .NET connection strings can be accessed in the same way:

```
module.postgres.read_replica_extra_dotnet_connection_strings["replica-2"]["reporting"]
```

**Limitations**

- Read replicas are only created when `use_azure = true`.
- Read replicas are read-only and cannot be used for workloads that require writes.
- Replication is asynchronous, so a small amount of replication lag may exist between the primary and replica servers.
- Creating a read replica incurs the cost of an additional Azure PostgreSQL Flexible Server.

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

### `read_replica_hosts`

Map of read replica numbers to hostnames.

### `extra_databases`

List of names of any additional databases deployed alongside the primary.

### `url`

The URL used to connect to the PostgreSQL instance.

### `extra_database_urls`

A map of additional database names to PostgreSQL connection URLs.

### `read_replica_urls`

Map of read replica numbers to PostgreSQL connection URLs.

### `read_replica_extra_database_urls`

Map of read replica numbers to additional PostgreSQL database connection URLs.

### `dotnet_connection_string`

A connection string that's compatible with .NET applications to the PostgreSQL instance.

### `extra_dotnet_connection_strings`

A map of additional database names to .NET connection strings.

### `read_replica_dotnet_connection_strings`

Map of read replica numbers to .NET connection strings.

### `read_replica_extra_dotnet_connection_strings`

Map of read replica numbers to .NET connection strings for additional PostgreSQL databases.

### `azure_backup_storage_account_name`

The name of the storage account that can be used to store backups.

### `azure_backup_storage_container_name`

The name of the storage container that can be used to store backups.

### `azure_server_id`

ID of the database server in terraform. It can be used to create more databases in the same server (only available when using Azure postgres).

### `read_replica_server_ids`

Map of read replica numbers to Azure PostgreSQL Flexible Server resource IDs.
