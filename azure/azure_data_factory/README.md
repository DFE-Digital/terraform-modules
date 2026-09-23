# Azure Data Factory

Opinionated Terraform module to deploy Azure Data Factory with a locked-down surface area.

## Scope

This module creates:
- `azurerm_data_factory`
- GitHub source control when the current environment matches `git_enabled_environment`

The module is intentionally opinionated and does not expose broad Data Factory configuration options.

## Usage

```hcl
module "data_factory" {
  count  = var.enable_adf ? 1 : 0
  source = "./vendor/modules/aks/azure/azure_data_factory"

  environment             = var.environment
  azure_resource_prefix   = var.azure_resource_prefix
  service_name            = var.service_name
  service_short           = var.service_short
  config_short            = var.config_short
  azure_enable_monitoring = false

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
