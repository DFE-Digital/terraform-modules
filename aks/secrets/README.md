# AKS Secrets

Terraform code for accessing the secrets.

## Usage

```terraform
module "secrets" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/secrets?ref=stable"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = local.service_short
  config_short          = var.config_short
}
```

## Outputs

### `key_vault_name`

The name of the Azure key vault used to fetch the secrets.

### `application`

The map of application secrets.

### `infrastructure`

The map of infrastructure secrets.
