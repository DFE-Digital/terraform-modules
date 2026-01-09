## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_airbyte"></a> [airbyte](#provider\_airbyte) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | 6.6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_data"></a> [cluster\_data](#module\_cluster\_data) | ../cluster_data | n/a |
| <a name="module_streams_update_job"></a> [streams\_update\_job](#module\_streams\_update\_job) | ../job_configuration | n/a |

## Resources

| Name | Type |
|------|------|
| [airbyte_connection.connection](https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs/resources/connection) | resource |
| [airbyte_destination_bigquery.destination_bigquery](https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs/resources/destination_bigquery) | resource |
| [airbyte_source_postgres.source_postgres](https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs/resources/source_postgres) | resource |
| [airbyte_source_postgres.source_postgres_container](https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs/resources/source_postgres) | resource |
| [google_bigquery_dataset.internal](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset.main](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_iam_member.appender](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_bigquery_dataset_iam_member.appender_internal](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_bigquery_dataset_iam_member.owner](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_bigquery_dataset_iam_member.owner_internal](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_project_iam_member.appender](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.viewer](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/project_iam_member) | resource |
| [google_service_account.appender](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.appender](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/service_account_iam_binding) | resource |
| [kubernetes_job.airbyte-database-setup](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_secret.airbyte-sql](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_user_assigned_identity.gcp_wif](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [google_kms_crypto_key.main](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.main](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/data-sources/kms_key_ring) | data source |
| [google_project.main](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Airbyte client id | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Airbyte client secret | `string` | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | AKS cluster name e.g. test, production... Required | `string` | n/a | yes |
| <a name="input_config_map_ref"></a> [config\_map\_ref](#input\_config\_map\_ref) | formerly: module.application\_configuration.kubernetes\_config\_map\_name | `string` | n/a | yes |
| <a name="input_connection_status"></a> [connection\_status](#input\_connection\_status) | Connectin status, either active or inactive | `string` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | formerly: module.cluster\_data.configuration\_map.cpu\_min | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | database name | `string` | n/a | yes |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Current application environment | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_gcp_dataset"></a> [gcp\_dataset](#input\_gcp\_dataset) | Name of an existing dataset. Optional: if not provided, create a new dataset | `string` | `null` | no |
| <a name="input_gcp_dataset_internal"></a> [gcp\_dataset\_internal](#input\_gcp\_dataset\_internal) | Name of an existing dataset. Optional: if not provided, create a new dataset | `string` | `null` | no |
| <a name="input_gcp_key"></a> [gcp\_key](#input\_gcp\_key) | Name of an existing customer-managed encryption key (CMEK). Required when creating the dataset | `string` | `null` | no |
| <a name="input_gcp_keyring"></a> [gcp\_keyring](#input\_gcp\_keyring) | Name of an existing keyring. Required when creating the dataset | `string` | `null` | no |
| <a name="input_gcp_policy_tag_id"></a> [gcp\_policy\_tag\_id](#input\_gcp\_policy\_tag\_id) | Policy tag ID. Required when creating the dataset | `number` | `null` | no |
| <a name="input_gcp_table_deletion_protection"></a> [gcp\_table\_deletion\_protection](#input\_gcp\_table\_deletion\_protection) | Prevents deletion of the event table. Default: true | `bool` | `true` | no |
| <a name="input_gcp_taxonomy_id"></a> [gcp\_taxonomy\_id](#input\_gcp\_taxonomy\_id) | Policy tags taxonomy ID. Required when creating the dataset | `number` | `null` | no |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | AKS Namespace where the service is deployed to. Required | `string` | n/a | yes |
| <a name="input_postgres_url"></a> [postgres\_url](#input\_postgres\_url) | Postgres connection url | `string` | n/a | yes |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | postgres version | `string` | n/a | yes |
| <a name="input_repl_password"></a> [repl\_password](#input\_repl\_password) | Password of the replication user | `string` | `null` | no |
| <a name="input_schedule_type"></a> [schedule\_type](#input\_schedule\_type) | Connection schedule type, either manual or cron. Cron will run on hourly schedule | `string` | `"cron"` | no |
| <a name="input_secret_ref"></a> [secret\_ref](#input\_secret\_ref) | formerly: module.application\_configuration.kubernetes\_secret\_name | `string` | n/a | yes |
| <a name="input_server_url"></a> [server\_url](#input\_server\_url) | Server url | `string` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_use_azure"></a> [use\_azure](#input\_use\_azure) | Whether to deploy using Azure Postgres | `bool` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Airbyte workspace id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_google_cloud_credentials"></a> [google\_cloud\_credentials](#output\_google\_cloud\_credentials) | Credentials for Google workload identity federation |
| <a name="output_password"></a> [password](#output\_password) | n/a |
