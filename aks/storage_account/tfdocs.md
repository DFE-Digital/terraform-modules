# AKS Storage Account Module

Terraform code for deploying an Azure Storage Account.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_encryption_scope.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_encryption_scope) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Current namespace | `string` | n/a | yes |
| environment | Current application environment | `string` | n/a | yes |
| azure_resource_prefix | Prefix of Azure resources for the service | `string` | n/a | yes |
| service_name | Name of the service | `string` | n/a | yes |
| service_short | Short name of the service | `string` | n/a | yes |
| config_short | Short name of the configuration | `string` | n/a | yes |
| name | Name of the storage account (without prefix and suffix) | `string` | `null` | no |
| account_kind | Kind of storage account | `string` | `"StorageV2"` | no |
| account_tier | Tier of storage account | `string` | `"Standard"` | no |
| account_replication_type | Replication type for the storage account | `string` | `"LRS"` | no |
| production_replication_type | Replication type to use for production environments | `string` | `"GRS"` | no |
| use_production_replication | Whether to use the production replication type. If true, overrides account_replication_type with production_replication_type. | `bool` | `false` | no |
| access_tier | Access tier for the storage account | `string` | `"Hot"` | no |
| min_tls_version | Minimum TLS version required | `string` | `"TLS1_2"` | no |
| enable_https_traffic_only | Forces HTTPS if enabled | `bool` | `true` | no |
| public_network_access_enabled | Whether public network access is allowed for the storage account | `bool` | `false` | no |
| allow_nested_items_to_be_public | Allow or disallow nested items within this Account to opt into being public | `bool` | `false` | no |
| cross_tenant_replication_enabled | Allow or disallow cross-tenant replication | `bool` | `false` | no |
| infrastructure_encryption_enabled | Enable infrastructure encryption for the storage account | `bool` | `true` | no |
| last_access_time_enabled | Enable last access time tracking for blobs | `bool` | `true` | no |
| blob_delete_retention_days | Number of days to retain deleted blobs | `number` | `7` | no |
| container_delete_retention_days | Number of days to retain deleted containers | `number` | `7` | no |
| create_encryption_scope | Whether to create a Microsoft-managed encryption scope | `bool` | `true` | no |
| encryption_scope_name | Name of the encryption scope to create | `string` | `"microsoftmanaged"` | no |
| containers | List of containers to create on the storage account | `list(object({ name = string, access_type = string }))` | `[]` | no |
| network_rules | Network rules for the storage account | `object({ default_action = string, bypass = list(string), ip_rules = list(string), virtual_network_subnet_ids = list(string) })` | `{ default_action = "Deny", bypass = ["AzureServices"], ip_rules = [], virtual_network_subnet_ids = [] }` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Account |
| name | The name of the Storage Account |
| primary_access_key | The primary access key for the Storage Account |
| primary_connection_string | The primary connection string for the Storage Account |
| primary_blob_endpoint | The primary blob endpoint URL |
| containers | A map of container names to their properties |
