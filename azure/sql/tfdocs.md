## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_monitor_metric_alert.cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_mssql_database.extra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_private_endpoint.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_monitor_diagnostic_categories.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |
| [azurerm_private_dns_zone.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Password of the admin user | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Username of the admin user | `string` | `null` | no |
| <a name="input_alert_window_size"></a> [alert\_window\_size](#input\_alert\_window\_size) | The period of time that is used to monitor alert activity e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly. | `string` | `"PT5M"` | no |
| <a name="input_azure_backup_storage_private_endpoint_enabled"></a> [azure\_backup\_storage\_private\_endpoint\_enabled](#input\_azure\_backup\_storage\_private\_endpoint\_enabled) | Use a private endpoint for backup storage account access | `bool` | `false` | no |
| <a name="input_azure_backup_storage_public_network_access_enabled"></a> [azure\_backup\_storage\_public\_network\_access\_enabled](#input\_azure\_backup\_storage\_public\_network\_access\_enabled) | Whether public network access is allowed for the storage account | `bool` | `true` | no |
| <a name="input_azure_cpu_threshold"></a> [azure\_cpu\_threshold](#input\_azure\_cpu\_threshold) | n/a | `number` | `80` | no |
| <a name="input_azure_enable_backup_storage"></a> [azure\_enable\_backup\_storage](#input\_azure\_enable\_backup\_storage) | n/a | `bool` | `true` | no |
| <a name="input_azure_enable_monitoring"></a> [azure\_enable\_monitoring](#input\_azure\_enable\_monitoring) | n/a | `bool` | `true` | no |
| <a name="input_azure_memory_threshold"></a> [azure\_memory\_threshold](#input\_azure\_memory\_threshold) | n/a | `number` | `80` | no |
| <a name="input_azure_name_override"></a> [azure\_name\_override](#input\_azure\_name\_override) | Replace the generated name with hardcoded name | `string` | `null` | no |
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_azure_sql_sku"></a> [azure\_sql\_sku](#input\_azure\_sql\_sku) | SKU of the Azure SQL database | `string` | `"GP_Gen5_2"` | no |
| <a name="input_azure_storage_threshold"></a> [azure\_storage\_threshold](#input\_azure\_storage\_threshold) | n/a | `number` | `80` | no |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_create_database"></a> [create\_database](#input\_create\_database) | Create default database. If the app creates the database instead of this module, set to false. Default: true | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_extra_databases"></a> [extra\_databases](#input\_extra\_databases) | Additional PostgreSQL databases to create on the same PostgreSQL server | `list(string)` | `[]` | no |
| <a name="input_server_name_suffix"></a> [server\_name\_suffix](#input\_server\_name\_suffix) | The name of the Azure SQL, SQL logical server. If not provided, a name will be generated based on the service\_short and config\_short variables. | `string` | `null` | no |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | Version of the Azure SQL logical server | `string` | `"12.0"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Whether replicas of the database will be spread across multiple availability zones | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dotnet_connection_string"></a> [dotnet\_connection\_string](#output\_dotnet\_connection\_string) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
