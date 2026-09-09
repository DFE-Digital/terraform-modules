## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_mssql_database.extra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_private_endpoint.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_monitor_diagnostic_categories.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
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
| <a name="input_databases"></a> [databases](#input\_databases) | Map of database names and their configurations. | `map(any)` | `{}` | no |
| <a name="input_dnszone_id"></a> [dnszone\_id](#input\_dnszone\_id) | n/a | `any` | `null` | no |
| <a name="input_dnszone_name"></a> [dnszone\_name](#input\_dnszone\_name) | n/a | `any` | `null` | no |
| <a name="input_enable_immutable_backups"></a> [enable\_immutable\_backups](#input\_enable\_immutable\_backups) | Specifies if the backups are immutable | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_extra_databases"></a> [extra\_databases](#input\_extra\_databases) | Additional SQL logical server databases to create on the same SQL logical server | `list(string)` | `[]` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | List of firewall rules to create for the SQL logical server. Each rule is an object with name, start\_ip\_address, and end\_ip\_address. | `list(object({ name = string, ip_address = optional(string), start_ip_address = optional(string), end_ip_address = optional(string) }))` | `[]` | no |
| <a name="input_lt_ret_pol_monthly_retention"></a> [lt\_ret\_pol\_monthly\_retention](#input\_lt\_ret\_pol\_monthly\_retention) | Specifies the number of months to retain the backup for. PT0S Period Time zero seconds. The value is a duration in ISO 8601 format. | `string` | `"PT0S"` | no |
| <a name="input_lt_ret_pol_week_of_year"></a> [lt\_ret\_pol\_week\_of\_year](#input\_lt\_ret\_pol\_week\_of\_year) | Specifies the week of the year to retain the backup for. The value is a number between 1 and 52. | `number` | `1` | no |
| <a name="input_lt_ret_pol_weekly_retention"></a> [lt\_ret\_pol\_weekly\_retention](#input\_lt\_ret\_pol\_weekly\_retention) | Specifies the number of weeks to retain the backup for. PT0S Period Time zero seconds. The value is a duration in ISO 8601 format. | `string` | `"PT0S"` | no |
| <a name="input_lt_ret_pol_yearly_retention"></a> [lt\_ret\_pol\_yearly\_retention](#input\_lt\_ret\_pol\_yearly\_retention) | Specifies the number of years to retain the backup for. PT0S Period Time zero seconds. The value is a duration in ISO 8601 format. | `string` | `"PT0S"` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | n/a | `any` | `null` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | n/a | <pre>map(object({<br/>    resource_id = string<br/>    dns_zone_id = string<br/>    subresource = string<br/>  }))</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for the SQL logical server | `bool` | `true` | no |
| <a name="input_server_name_suffix"></a> [server\_name\_suffix](#input\_server\_name\_suffix) | The name of the Azure SQL, SQL logical server. If not provided, a name will be generated based on the service\_short and config\_short variables. | `string` | `null` | no |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | Version of the Azure SQL logical server | `string` | `"12.0"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_st_ret_pol_backup_interval_in_hours"></a> [st\_ret\_pol\_backup\_interval\_in\_hours](#input\_st\_ret\_pol\_backup\_interval\_in\_hours) | Specifies the interval in hours between backups. The value is a number between 1 and 24. | `number` | `12` | no |
| <a name="input_st_ret_pol_retention_days"></a> [st\_ret\_pol\_retention\_days](#input\_st\_ret\_pol\_retention\_days) | Specifies the number of days to retain the backup for. The value is a number between 1 and 35. | `number` | `7` | no |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | Storage account type for the Azure SQL database. Options: LRS, GRS, ZRS, RAGRS, RAGZRS | `string` | `"Geo"` | no |
| <a name="input_threat_pol_disabled_alerts"></a> [threat\_pol\_disabled\_alerts](#input\_threat\_pol\_disabled\_alerts) | Specifies the list of alerts that are disabled. Possible values are: Sql\_Injection, Sql\_Injection\_Vulnerability, Access\_Anomaly, Data\_Exfiltration, Data\_Exfiltration\_Vulnerability, Brute\_Force, Sql\_Injection\_Brute\_Force | `list(string)` | `[]` | no |
| <a name="input_threat_pol_email_account_admins"></a> [threat\_pol\_email\_account\_admins](#input\_threat\_pol\_email\_account\_admins) | Specifies whether to send email notifications to the account administrators when a threat detection alert is triggered. Possible values are: Enabled, Disabled | `string` | `"Disabled"` | no |
| <a name="input_threat_pol_email_addresses"></a> [threat\_pol\_email\_addresses](#input\_threat\_pol\_email\_addresses) | Specifies the list of email addresses to send notifications to when a threat detection alert is triggered. | `list(string)` | `[]` | no |
| <a name="input_threat_pol_retention_days"></a> [threat\_pol\_retention\_days](#input\_threat\_pol\_retention\_days) | Specifies the number of days to retain threat detection logs. The value is a number between 0 and 365. | `number` | `0` | no |
| <a name="input_threat_pol_state"></a> [threat\_pol\_state](#input\_threat\_pol\_state) | Specifies the state of the threat detection policy. Possible values are: Enabled, Disabled | `string` | `"Disabled"` | no |
| <a name="input_threat_pol_storage_account_access_key"></a> [threat\_pol\_storage\_account\_access\_key](#input\_threat\_pol\_storage\_account\_access\_key) | Specifies the access key of the storage account to store threat detection logs. | `string` | `""` | no |
| <a name="input_threat_pol_storage_endpoint"></a> [threat\_pol\_storage\_endpoint](#input\_threat\_pol\_storage\_endpoint) | Specifies the endpoint of the storage account to store threat detection logs. | `string` | `""` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Whether replicas of the database will be spread across multiple availability zones | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dotnet_connection_string"></a> [dotnet\_connection\_string](#output\_dotnet\_connection\_string) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
