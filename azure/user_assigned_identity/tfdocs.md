## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_user_assigned_identity.app_service_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | The short name of the environment configuration e.g. dv, ts, pd | `string` | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | The short name of the environment e.g. d01, t01, p01 | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The full name of the application service environment e.g. development, test, production | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The full name of the service e.g. get-information-about-schools | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | The short name of the service e.g. gias | `string` | n/a | yes |
| <a name="input_subscription_short"></a> [subscription\_short](#input\_subscription\_short) | The short name of the subscription e.g. s189 | `string` | n/a | yes |
| <a name="input_user_assigned_identity_short"></a> [user\_assigned\_identity\_short](#input\_user\_assigned\_identity\_short) | A short name that will be used in the user assigned identity name e.g. crm = s189d01-crm-dev-crm-id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the user assigned identity |
| <a name="output_name"></a> [name](#output\_name) | The name of the user assigned identity |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the user assigned identity |
