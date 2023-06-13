# AKS Application Configuration

Terraform code for generating the application configuration.

## Usage

```terraform
module "application_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=stable"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = local.service_short
  config_short          = var.config_short

  config_variables      = {}
  config_variables_path = "config.yaml"

  secret_variables      = {}
}
```

### Rails applications

If `is_rails_application` is set to `true`, this will automatically set the following config variables:

```sh
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

## Outputs

### `kubernetes_config_map_name`

The name of the Kubernetes `ConfigMap`.

### `kubernetes_secret_name`

The name of the Kubernetes secrets.
