## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | 6.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_data"></a> [cluster\_data](#module\_cluster\_data) | ../cluster_data | n/a |

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset.main](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_iam_binding.appender](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_dataset_iam_binding) | resource |
| [google_bigquery_table.events](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/bigquery_table) | resource |
| [google_kms_crypto_key.bigquery](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_member.bigquery](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_key_ring.bigquery](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/kms_key_ring) | resource |
| [google_service_account.appender](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.appender](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/resources/service_account_iam_binding) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_user_assigned_identity.gcp_wif](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [google_bigquery_default_service_account.main](https://registry.terraform.io/providers/hashicorp/google/6.6.0/docs/data-sources/bigquery_default_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | AKS cluster name e.g. test, production... | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Service environment name e.g. production, test, pr-1234... | `string` | n/a | yes |
| <a name="input_gcp_dataset"></a> [gcp\_dataset](#input\_gcp\_dataset) | Name of an existing dataset. Optional: if not provided, create a new dataset | `string` | `null` | no |
| <a name="input_gcp_key"></a> [gcp\_key](#input\_gcp\_key) | Name of an existing customer-managed encryption key (CMEK). Optional: if not provided, create a new key | `string` | `null` | no |
| <a name="input_gcp_keyring"></a> [gcp\_keyring](#input\_gcp\_keyring) | Name of an existing keyring. Optional: if not provided, create a new keyring | `string` | `null` | no |
| <a name="input_gcp_policy_tag_id"></a> [gcp\_policy\_tag\_id](#input\_gcp\_policy\_tag\_id) | Policy tag ID | `number` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | ID of the Google cloud project e.g. 'rugged-abacus-218110', 'apply-for-qts-in-england'... | `string` | n/a | yes |
| <a name="input_gcp_project_number"></a> [gcp\_project\_number](#input\_gcp\_project\_number) | Google cloud project number | `number` | n/a | yes |
| <a name="input_gcp_table_deletion_protection"></a> [gcp\_table\_deletion\_protection](#input\_gcp\_table\_deletion\_protection) | Prevents deletion of the event table. Default: true | `bool` | `true` | no |
| <a name="input_gcp_taxonomy_id"></a> [gcp\_taxonomy\_id](#input\_gcp\_taxonomy\_id) | Policy tags taxonomy ID | `number` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | AKS Namespace where the service is deployed to | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name for the service e.g. att, aytq... | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bigquery_dataset"></a> [bigquery\_dataset](#output\_bigquery\_dataset) | Bigquery dataset name |
| <a name="output_bigquery_project_id"></a> [bigquery\_project\_id](#output\_bigquery\_project\_id) | ID of the Google cloud project e.g. 'rugged-abacus-218110', 'apply-for-qts-in-england'... |
| <a name="output_bigquery_table_name"></a> [bigquery\_table\_name](#output\_bigquery\_table\_name) | Biquery events table name |
| <a name="output_dfe_analytics_variables_map"></a> [dfe\_analytics\_variables\_map](#output\_dfe\_analytics\_variables\_map) | Map of environment variables required for dfe-analytics. Merge with application configuration secrets. |
| <a name="output_google_cloud_credentials"></a> [google\_cloud\_credentials](#output\_google\_cloud\_credentials) | Credentials for Google workload identity federation |
