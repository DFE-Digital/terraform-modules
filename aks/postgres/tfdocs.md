## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.memory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_postgresql_flexible_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.azure_extensions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_configuration.connection_throttling](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_configuration.max_connections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_database.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_storage_account.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_monitor_diagnostic_categories.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |
| [azurerm_private_dns_zone.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Password of the admin user | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Username of the admin user | `string` | `null` | no |
| <a name="input_alert_window_size"></a> [alert\_window\_size](#input\_alert\_window\_size) | The period of time that is used to monitor alert activity e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly. | `string` | `"PT5M"` | no |
| <a name="input_azure_cpu_threshold"></a> [azure\_cpu\_threshold](#input\_azure\_cpu\_threshold) | n/a | `number` | `80` | no |
| <a name="input_azure_enable_backup_storage"></a> [azure\_enable\_backup\_storage](#input\_azure\_enable\_backup\_storage) | n/a | `bool` | `true` | no |
| <a name="input_azure_enable_high_availability"></a> [azure\_enable\_high\_availability](#input\_azure\_enable\_high\_availability) | n/a | `bool` | `false` | no |
| <a name="input_azure_enable_monitoring"></a> [azure\_enable\_monitoring](#input\_azure\_enable\_monitoring) | n/a | `bool` | `true` | no |
| <a name="input_azure_extensions"></a> [azure\_extensions](#input\_azure\_extensions) | n/a | `list(string)` | `[]` | no |
| <a name="input_azure_maintenance_window"></a> [azure\_maintenance\_window](#input\_azure\_maintenance\_window) | n/a | <pre>object({<br>    day_of_week  = optional(number)<br>    start_hour   = optional(number)<br>    start_minute = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_azure_memory_threshold"></a> [azure\_memory\_threshold](#input\_azure\_memory\_threshold) | n/a | `number` | `80` | no |
| <a name="input_azure_name_override"></a> [azure\_name\_override](#input\_azure\_name\_override) | Replace the generated name with hardcoded name | `string` | `null` | no |
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_azure_sku_name"></a> [azure\_sku\_name](#input\_azure\_sku\_name) | n/a | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_azure_storage_mb"></a> [azure\_storage\_mb](#input\_azure\_storage\_mb) | n/a | `number` | `32768` | no |
| <a name="input_azure_storage_threshold"></a> [azure\_storage\_threshold](#input\_azure\_storage\_threshold) | n/a | `number` | `80` | no |
| <a name="input_cluster_configuration_map"></a> [cluster\_configuration\_map](#input\_cluster\_configuration\_map) | Configuration map for the cluster | <pre>object({<br>    resource_group_name = string,<br>    resource_prefix     = string,<br>    dns_zone_prefix     = optional(string),<br>    cpu_min             = number<br>  })</pre> | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the instance | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Current namespace | `string` | n/a | yes |
| <a name="input_server_docker_image"></a> [server\_docker\_image](#input\_server\_docker\_image) | Database image to use with kubernetes deployment, eg. postgis/postgis:16-3.4 | `string` | `"postgres:16-alpine"` | no |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | Version of PostgreSQL server | `string` | `"16"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_use_azure"></a> [use\_azure](#input\_use\_azure) | Whether to deploy using Azure Redis Cache service | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_backup_storage_account_name"></a> [azure\_backup\_storage\_account\_name](#output\_azure\_backup\_storage\_account\_name) | n/a |
| <a name="output_azure_backup_storage_container_name"></a> [azure\_backup\_storage\_container\_name](#output\_azure\_backup\_storage\_container\_name) | n/a |
| <a name="output_azure_server_id"></a> [azure\_server\_id](#output\_azure\_server\_id) | n/a |
| <a name="output_dotnet_connection_string"></a> [dotnet\_connection\_string](#output\_dotnet\_connection\_string) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_password"></a> [password](#output\_password) | n/a |
| <a name="output_port"></a> [port](#output\_port) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
| <a name="output_username"></a> [username](#output\_username) | n/a |
