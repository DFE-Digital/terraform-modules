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
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | The short name of the environment configuration e.g. dv, ts, pd | `string` | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | The short name of the environment e.g. d01, t01, p01 | `string` | n/a | yes |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | The maximum number of elastic workers for the application service plan. | `number` | `null` | no |
| <a name="input_premium_plan_auto_scale_enabled"></a> [premium\_plan\_auto\_scale\_enabled](#input\_premium\_plan\_auto\_scale\_enabled) | Whether to enable auto-scaling for the premium application service plan. | `bool` | `false` | no |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | The short name of the service e.g. gias | `string` | n/a | yes |
| <a name="input_sp_infix"></a> [sp\_infix](#input\_sp\_infix) | An optional infix to include in the generated App Service Plan name. | `string` | `""` | no |
| <a name="input_sp_name"></a> [sp\_name](#input\_sp\_name) | Override the generated App Service Plan name. | `string` | `""` | no |
| <a name="input_sp_os_type"></a> [sp\_os\_type](#input\_sp\_os\_type) | The operating system type of the application service plan. | `string` | `"Windows"` | no |
| <a name="input_sp_sku_name"></a> [sp\_sku\_name](#input\_sp\_sku\_name) | The SKU name of the application service plan. | `string` | `"S1"` | no |
| <a name="input_subscription_short"></a> [subscription\_short](#input\_subscription\_short) | The short name of the subscription e.g. s189 | `string` | n/a | yes |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | The number of workers (instances) for the application service plan. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the App Service Plan |
| <a name="output_name"></a> [name](#output\_name) | The name of the App Service Plan |
