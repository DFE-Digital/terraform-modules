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
| [azurerm_private_endpoint.function_app_ep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.web_app_ep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_windows_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |
| [azurerm_windows_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Whether to enable the Always On feature for the Web App. | `bool` | `true` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | A map of key-value pairs to configure the Web App settings. | `map(string)` | `{}` | no |
| <a name="input_app_type"></a> [app\_type](#input\_app\_type) | The type of application to be deployed (e.g., web, function). | `string` | n/a | yes |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | The application stack configuration for the Web App. | <pre>object({<br/>    dotnet_core_version = optional(string)<br/>    dotnet_version      = optional(string)<br/>    java_version        = optional(string)<br/>    node_version        = optional(string)<br/>    php_version         = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | The short name of the environment configuration e.g. dv, ts, pd | `string` | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | The short name of the environment e.g. d01, t01, p01 | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The full name of the application service environment e.g. development, test, production | `string` | n/a | yes |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | The FTPS state for the Web App. Possible values are 'AllAllowed', 'FtpsOnly', or 'Disabled'. | `string` | `"Disabled"` | no |
| <a name="input_function_app_name"></a> [function\_app\_name](#input\_function\_app\_name) | The name of the Function App that gets added as a suffix to the standard resource name. | `string` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The path to the health check endpoint for the Web App. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace to which diagnostic logs will be sent. | `string` | `null` | no |
| <a name="input_logs"></a> [logs](#input\_logs) | The logging configuration for the Web App. | <pre>object({<br/>    detailed_error_messages = optional(bool)<br/>    failed_request_tracing  = optional(bool)<br/>    http_logs = optional(object({<br/>      file_system = optional(object({<br/>        retention_in_days = optional(number)<br/>        retention_in_mb   = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | The maximum number of elastic workers for the application service plan. | `number` | `2` | no |
| <a name="input_premium_plan_auto_scale_enabled"></a> [premium\_plan\_auto\_scale\_enabled](#input\_premium\_plan\_auto\_scale\_enabled) | Whether to enable auto-scaling for the premium application service plan. | `bool` | `false` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | The id of the subnet which will be used by the private endpoint | `string` | `null` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | A map defining one or more private endpoints for the Web App | <pre>map(object({<br/>    subnet_id           = string<br/>    private_dns_zone_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for the Web App. | `bool` | `true` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The full name of the service e.g. get-information-about-schools | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | The short name of the service e.g. gias | `string` | n/a | yes |
| <a name="input_sp_name"></a> [sp\_name](#input\_sp\_name) | The name of the application service plan. | `string` | `""` | no |
| <a name="input_sp_os_type"></a> [sp\_os\_type](#input\_sp\_os\_type) | The operating system type of the application service plan. | `string` | `"Windows"` | no |
| <a name="input_sp_sku_name"></a> [sp\_sku\_name](#input\_sp\_sku\_name) | The SKU name of the application service plan. | `string` | `"S1"` | no |
| <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key) | The access key for the storage account used by the Function App. | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account that gets added as a suffix to the standard resource name. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The id of the subnet which will be used by this Web App | `string` | `null` | no |
| <a name="input_subscription_short"></a> [subscription\_short](#input\_subscription\_short) | The short name of the subscription e.g. s189 | `string` | n/a | yes |
| <a name="input_web_app_name"></a> [web\_app\_name](#input\_web\_app\_name) | The name of the Web App that gets added as a suffix to the standard resource name. | `string` | `null` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | The number of workers (instances) for the application service plan. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | The default hostname of the App Service |
| <a name="output_id"></a> [id](#output\_id) | The ID of the App Service |
| <a name="output_name"></a> [name](#output\_name) | The name of the App Service |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | The outbound IP addresses of the App Service |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | The possible outbound IP addresses of the App Service |
