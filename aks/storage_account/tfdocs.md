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
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_encryption_scope.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_encryption_scope) | resource |
| [azurerm_storage_management_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_blob_delete_after_days"></a> [blob\_delete\_after\_days](#input\_blob\_delete\_after\_days) | Number of days after which blobs will be deleted. Set to 0 to disable automatic deletion. | `number` | `7` | no |
| <a name="input_blob_delete_retention_days"></a> [blob\_delete\_retention\_days](#input\_blob\_delete\_retention\_days) | Number of days to retain deleted blobs | `number` | `7` | no |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_container_delete_retention_days"></a> [container\_delete\_retention\_days](#input\_container\_delete\_retention\_days) | Number of days to retain deleted containers | `number` | `7` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | List of containers to create on the storage account (all containers will be private) | `list(object({ name = string }))` | `[]` | no |
| <a name="input_create_encryption_scope"></a> [create\_encryption\_scope](#input\_create\_encryption\_scope) | Whether to create a Microsoft-managed encryption scope | `bool` | `true` | no |
| <a name="input_encryption_scope_name"></a> [encryption\_scope\_name](#input\_encryption\_scope\_name) | Name of the encryption scope to create | `string` | `"microsoftmanaged"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Enable infrastructure encryption for the storage account | `bool` | `true` | no |
| <a name="input_last_access_time_enabled"></a> [last\_access\_time\_enabled](#input\_last\_access\_time\_enabled) | Enable last access time tracking for blobs | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the storage account (without prefix and suffix) | `string` | `null` | no |
| <a name="input_production_replication_type"></a> [production\_replication\_type](#input\_production\_replication\_type) | Replication type for production environments. Non-production environments always use LRS for cost efficiency. | `string` | `"GRS"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for the storage account | `bool` | `false` | no |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_storage_account_name_override"></a> [storage\_account\_name\_override](#input\_storage\_account\_name\_override) | Override the generated storage account name with a custom name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_containers"></a> [containers](#output\_containers) | A map of container names to their properties |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Storage Account |
| <a name="output_name"></a> [name](#output\_name) | The name of the Storage Account |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the Storage Account |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint URL |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the Storage Account |
