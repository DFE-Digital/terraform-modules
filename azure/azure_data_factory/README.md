# Azure Data Factory

Opinionated Terraform module to deploy Azure Data Factory with a locked-down surface area.

## Scope

This module creates:
- `azurerm_data_factory`
- a default Azure Blob Storage linked service for that account
- GitHub source control when the current environment matches `git_enabled_environment`
- SQL Server, PostgreSQL flexible server, and Azure Storage linked services supplied by the caller
- managed private endpoints for supported resources when private-link details are supplied

The module is intentionally opinionated and does not expose broad Data Factory configuration options.

## Usage

```hcl
module "data_factory" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//data_factory?ref=stable"

  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = "apply-for-qts"
  service_short         = "afqts"
  config_short          = "dv"

  git_enabled_environment = "development"
  git_repository = {
    repository_name = "apply-for-qts"
    branch_name     = "main"    
  }
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
- Sensitive values such as connection strings and passwords are marked as sensitive in Terraform variables, but they may still appear in state.
- GitHub source control always uses the fixed account name `DFE-Digital`.
