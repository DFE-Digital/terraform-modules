# AKS Storage Account

Terraform code for deploying an Azure Storage Account with the recommended best practices and security settings.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  name = "myapp-storage"

  namespace             = var.namespace
  environment           = "${var.app_environment}${var.app_suffix}"
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = "my-service"
  service_short         = "msvc"
  config_short          = "dv"

  # Enable production-grade replication for production environments
  use_production_replication = var.app_environment == "production"

  # Create containers for the application
  containers = [
    {
      name        = "uploads",
      access_type = "private"
    },
    {
      name        = "reports",
      access_type = "private"
    }
  ]

  # Enable infrastructure encryption for additional security
  infrastructure_encryption_enabled = true

  # Create a Microsoft-managed encryption scope
  create_encryption_scope = true
  encryption_scope_name   = "microsoftmanaged"
}
```

### Custom name and location

You can specify a custom name and location for the storage account:

```terraform
module "temp_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  # Basics
  namespace             = var.namespace
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = var.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  # Override the generated name
  storage_account_name_override = "customstoragename"

  # Specify a custom location
  location_override = "UK South"

  # Explicitly depend on a resource
  depends_on_resources = [data.azurerm_resource_group.main]
}
```

### Conditional creation

You can conditionally create the storage account:

```terraform
module "sanitised_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  # Basics
  namespace             = var.namespace
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = var.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  # Only create in certain environments
  create_storage_account = var.enable_sanitised_storage

  # Configure a container
  containers = [
    {
      name        = "database-backup",
      access_type = "private"
    }
  ]
}
```

### Lifecycle management

The module supports creating lifecycle management policies:

```terraform
module "evidence_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  # Basics
  namespace             = var.namespace
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = var.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  # Use the default "delete after 7 days" policy
  default_management_policy = true

  # Or create custom management policies
  create_management_policy = true
  management_policy_rules = [
    {
      name    = "ArchiveAfter30Days"
      enabled = true
      filters = {
        blob_types = ["blockBlob"]
        prefix_match = ["archive/"]
      }
      actions = {
        base_blob = {
          tier_to_archive_after_days_since_modification_greater_than = 30
          delete_after_days_since_modification_greater_than = 365
        }
      }
    }
  ]
}
```

### Container access types

The `access_type` for containers can be one of:

- `private`: No anonymous access (default)
- `blob`: Anonymous read access for blobs only
- `container`: Anonymous read access for containers and blobs

### Environment-based replication

This module supports setting different replication types based on environment:

```terraform
# Use LRS for non-production environments and GRS for production
use_production_replication = var.app_environment == "production"
production_replication_type = "GRS"  # Default is GRS
```

## Security features

This module implements the following security features by default:

- HTTPS-only access is enforced
- Minimum TLS version is set to 1.2
- Public network access is denied by default (configurable)
- Cross-tenant replication is disabled
- Nested items are not allowed to be public
- Infrastructure encryption is enabled by default
- Blob delete retention policy is enabled (7 days by default)
- Container delete retention policy is enabled (7 days by default)
- Last access time tracking for blobs is enabled by default
- Microsoft-managed encryption scope can be created (enabled by default)

## Outputs

### `id`

The ID of the Storage Account.

### `name`

The name of the Storage Account.

### `primary_access_key`

The primary access key for the Storage Account.

### `primary_connection_string`

The primary connection string for the Storage Account.

### `primary_blob_endpoint`

The primary blob endpoint URL.

### `containers`

A map of container names to their properties.
