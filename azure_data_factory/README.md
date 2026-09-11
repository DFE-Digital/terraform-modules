# Azure Data Factory

Opinionated Terraform module to deploy Azure Data Factory with a locked-down surface area.

## Scope

This module creates:
- `azurerm_data_factory`
- a standard Azure Storage account for Data Factory use
- a default Azure Blob Storage linked service for that account
- GitHub source control when the current environment matches `git_enabled_environment`
- SQL Server, PostgreSQL flexible server, and Azure Storage linked services supplied by the caller
- managed private endpoints for supported resources when private-link details are supplied

The module is intentionally opinionated and does not expose broad Data Factory configuration options.

## Usage

```hcl
module "data_factory" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//data_factory?ref=stable"

  name                  = "etl"
  environment           = "development"
  service_short         = "etl"
  azure_resource_prefix = "dfe"
  resource_group_name   = "dfe-dev-rg"
  location              = "UK South"
  key_vault_name          = "my-shared-kv"
  git_enabled_environment = "development"

  git_repository = {
    repository_name = "data-factory-code"
    branch_name     = "main"
    root_folder     = "/"
  }

  sql_server_connections = [
    {
      name                  = "source-sql-01"
      server_name           = "my-sql-server.database.windows.net"
      database_name         = "source_db"
      username_secret_name  = "source-sql-username"
      password_secret_name  = "source-sql-password"
      use_private_link      = true
      private_link_target_resource_id = var.sql_private_endpoint_target_id
    }
  ]

  postgresql_connections = [
    {
      name                  = "source-pg-01"
      host_name             = "my-pg-flexible.postgres.database.azure.com"
      database_name         = "source_db"
      username_secret_name  = "source-pg-username"
      password_secret_name  = "source-pg-password"
      use_private_link      = true
      private_link_target_resource_id = var.pg_private_endpoint_target_id
    }
  ]

  storage_account_connections = [
    {
      name                  = "landing-storage"
      storage_account_name  = "mylandingstorage"
      use_private_link      = true
      private_link_target_resource_id = var.storage_private_endpoint_target_id
    }
  ]
}
```

## Environment behaviour

- Only one environment should be configured with GitHub source control by setting `git_enabled_environment`.
- The module uses the current `environment` value to decide if GitHub integration should be enabled.
- Other environments should be managed through separate Terraform and GitHub workflow runs for infrastructure creation and ADF internal promotion.

## Inputs

For the full list of inputs and outputs, see `tfdocs.md`.

## Notes

- This module creates an ADF instance with a system-assigned managed identity and enables managed virtual networks for private-link support.
- The standard storage account is created automatically unless `create_standard_storage_account` is set to `false`.
- Sensitive values such as connection strings and passwords are marked as sensitive in Terraform variables, but they may still appear in state.
- Where a connection object includes a secret-name field such as `connection_string_secret_name`, `password_secret_name`, or `username_secret_name`, the module reads the value from the key vault named by `key_vault_name`.
- GitHub source control always uses the fixed account name `DFE-Digital`.
