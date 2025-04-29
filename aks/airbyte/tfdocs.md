## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_airbyte"></a> [airbyte](#provider\_airbyte) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [airbyte_connection.connection](https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs/resources/connection) | resource |
| [airbyte_destination_bigquery.destination_bigquery](https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs/resources/destination_bigquery) | resource |
| [airbyte_source_postgres.source_postgres](https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs/resources/source_postgres) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_cluster_configuration_map"></a> [cluster\_configuration\_map](#input\_cluster\_configuration\_map) | Configuration map for the cluster | <pre>object({<br>    resource_group_name = string,<br>    resource_prefix     = string,<br>    dns_zone_prefix     = optional(string),<br>    cpu_min             = number<br>  })</pre> | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_connection_status"></a> [connection\_status](#input\_connection\_status) | Connectin status, either active or inactive | `string` | `null` | no |
| <a name="input_credentials_json"></a> [credentials\_json](#input\_credentials\_json) | Airbyte credentials json | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | database name | `string` | n/a | yes |
| <a name="input_dataset_id"></a> [dataset\_id](#input\_dataset\_id) | GCP dataset id | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project id | `string` | `null` | no |
| <a name="input_repl_password"></a> [repl\_password](#input\_repl\_password) | Password of the replication user | `string` | `null` | no |
| <a name="input_repl_user"></a> [repl\_user](#input\_repl\_user) | Name of the replication user | `string` | `null` | no |
| <a name="input_schedule_type"></a> [schedule\_type](#input\_schedule\_type) | Connection schedule type, either manual or cron. Cron will run on hourly schedule | `string` | `"manual"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_use_airbyte"></a> [use\_airbyte](#input\_use\_airbyte) | Whether to deploy using Azure Redis Cache service | `bool` | `false` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Airbyte workspace id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_id"></a> [connection\_id](#output\_connection\_id) | n/a |
| <a name="output_destination_id"></a> [destination\_id](#output\_destination\_id) | n/a |
| <a name="output_password"></a> [password](#output\_password) | n/a |
| <a name="output_source_id"></a> [source\_id](#output\_source\_id) | n/a |
