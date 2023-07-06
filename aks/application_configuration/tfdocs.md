## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.20 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_secrets"></a> [application\_secrets](#module\_application\_secrets) | ../secrets | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_secret.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_config_variables"></a> [config\_variables](#input\_config\_variables) | Additional configuration variables | `map(string)` | `{}` | no |
| <a name="input_config_variables_path"></a> [config\_variables\_path](#input\_config\_variables\_path) | Path to load additional configuration variables from | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_is_rails_application"></a> [is\_rails\_application](#input\_is\_rails\_application) | If true, sets config variables for a Rails application | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Current namespace | `string` | n/a | yes |
| <a name="input_secret_key_vault_short"></a> [secret\_key\_vault\_short](#input\_secret\_key\_vault\_short) | Short name of the key vault which stores application secrets | `string` | `null` | no |
| <a name="input_secret_variables"></a> [secret\_variables](#input\_secret\_variables) | Additional secret variables | `map(string)` | `{}` | no |
| <a name="input_secret_yaml_key"></a> [secret\_yaml\_key](#input\_secret\_yaml\_key) | If set, secrets will also be extracted from a YAML key | `string` | `null` | no |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubernetes_config_map_name"></a> [kubernetes\_config\_map\_name](#output\_kubernetes\_config\_map\_name) | n/a |
| <a name="output_kubernetes_secret_name"></a> [kubernetes\_secret\_name](#output\_kubernetes\_secret\_name) | n/a |
