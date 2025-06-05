# AKS Storage Account

Terraform code for deploying an Azure Storage Account with the recommended best practices and security settings.

**Note: This module creates storage accounts in the UK South region.**

## Terraform documentation

For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  name = "files"

  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = "msvc"
  config_short          = "dv"
  pr_number            = var.pr_number  # Required for review environments

  # Create containers for the application (all containers are private)
  containers = [
    { name = "uploads" },
    { name = "reports" }
  ]

  # Configure blob lifecycle management (default: delete after 7 days)
  blob_delete_after_days = 7  # Set to 0 to disable automatic deletion

  # Enable infrastructure encryption for additional security
  infrastructure_encryption_enabled = true

  # Create a Microsoft-managed encryption scope
  create_encryption_scope = true
  encryption_scope_name   = "microsoftmanaged"
}
```

### Storage Account Naming

The module automatically generates storage account names based on the environment:

**For review environments (`environment = "review"`):**

- Uses the PR number instead of environment name: `{prefix}{service}{config}{pr_number}sa`
- Example: `s189t01captrv1234sa` (for PR #1234)

**For non-review environments:**

- Excludes environment from name: `{prefix}{service}{config}sa`
- Example: `s189t01captrvsa`

```terraform
module "review_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  environment           = "review"
  pr_number            = var.pr_number  # Required for review environments
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  containers = [
    { name = "uploads" },
    { name = "reports" }
  ]
}
```

**GitHub Actions Integration:**
To use with GitHub Actions, pass the PR number via environment variable:

```yaml
- name: Terraform Apply
  env:
    TF_VAR_pr_number: ${{ github.event.pull_request.number }}
  run: terraform apply
```

### Custom name

You can specify a custom name for the storage account:

```terraform
module "temp_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  # Basics
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Override the generated name
  storage_account_name_override = "customstoragename"
}
```

### Production vs Non-Production Replication

The module automatically sets replication based on environment:

- **Non-Production** (any environment != "production"): **LRS** (cost-effective)
- **Production** (environment == "production"): **GRS** by default, configurable to **ZRS**

```terraform
module "prod_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  environment           = "production"  # Will use GRS by default
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Override production replication to use ZRS instead of GRS
  production_replication_type = "ZRS"  # Options: "GRS" or "ZRS"
}

module "dev_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  environment           = "development"  # Will automatically use LRS
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
}
```

### Blob Lifecycle Management

The module supports simple blob lifecycle management:

```terraform
module "temp_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Delete blobs after 30 days
  blob_delete_after_days = 30

  # Or disable automatic deletion
  blob_delete_after_days = 0
}
```

### Enabling Retention Policies

Retention policies are disabled by default for immediate deletion. For production environments where you want to retain deleted items, you can enable them:

```terraform
module "production_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Enable versioning and retention policies for production safety
  blob_versioning_enabled         = true
  blob_delete_retention_days      = 7
  container_delete_retention_days = 7
}
```

## Security features

This module implements the following security features by default:

- HTTPS-only access is enforced
- Minimum TLS version is set to 1.2
- Public network access is denied by default (configurable)
- Cross-tenant replication is disabled
- Nested items are not allowed to be public
- Infrastructure encryption is enabled by default
- All containers are created with private access (no anonymous access)
- Blob versioning is disabled by default (can be enabled by setting to `true`)
- Blob delete retention policy is disabled by default (can be enabled by setting a number of days)
- Container delete retention policy is disabled by default (can be enabled by setting a number of days)
- Last access time tracking for blobs is enabled by default
- Microsoft-managed encryption scope can be created (enabled by default)

## Environment-based Configuration

| Environment                               | Replication Type  | Override Available? |
| ----------------------------------------- | ----------------- | ------------------- |
| Non-Production (dev, test, staging, etc.) | **LRS** (forced)  | ❌ No               |
| Production                                | **GRS** (default) | ✅ Yes (GRS or ZRS) |

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
