## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_data_factory.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory) | resource |
| [azurerm_data_factory_managed_private_endpoint.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint) | resource |
| [azurerm_data_factory_managed_private_endpoint.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint) | resource |
| [azurerm_data_factory_managed_private_endpoint.standard_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint) | resource |
| [azurerm_data_factory_managed_private_endpoint.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint) | resource |
| [azurerm_storage_account.standard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.postgresql_connection_strings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.sql_connection_strings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.storage_connection_strings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Azure prefix used to construct globally unique Data Factory names. | `string` | n/a | yes |
| <a name="input_create_standard_storage_account"></a> [create\_standard\_storage\_account](#input\_create\_standard\_storage\_account) | Whether to create a standard storage account for the Data Factory to use by default. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment used for resource naming and tagging. | `string` | n/a | yes |
| <a name="input_git_enabled_environment"></a> [git\_enabled\_environment](#input\_git\_enabled\_environment) | Environment name for which GitHub source control should be enabled. Other environments are expected to be managed by separate GitHub workflows. | `string` | `"development"` | no |
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | GitHub repository connection for Data Factory source control. Only GitHub is supported. | <pre>object({<br/>    repository_name    = string<br/>    branch_name        = string<br/>    root_folder        = optional(string, "/")<br/>    publishing_enabled = optional(bool, true)<br/>    host_name          = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Name of the Azure Key Vault from which credential-backed connection values should be read. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location for the Data Factory. | `string` | n/a | yes |
| <a name="input_postgresql_connections"></a> [postgresql\_connections](#input\_postgresql\_connections) | PostgreSQL connections represented by Key Vault secret names. | <pre>list(object({<br/>    name                        = string<br/>    connection_string_secret_name = string<br/>    create_private_endpoint     = bool<br/>    private_link_target_resource_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the Data Factory will be deployed. | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short service identifier used for resource naming and tagging. | `string` | n/a | yes |
| <a name="input_sql_server_connections"></a> [sql\_server\_connections](#input\_sql\_server\_connections) | SQL Server connections represented by Key Vault secret names. | <pre>list(object({<br/>    name                        = string<br/>    connection_string_secret_name = string<br/>    create_private_endpoint     = bool<br/>    private_link_target_resource_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_account_connections"></a> [storage\_account\_connections](#input\_storage\_account\_connections) | List of Azure Storage linked service definitions. | <pre>list(object({<br/>    name                            = string<br/>    description                     = optional(string)<br/>    connection_string_secret_name   = optional(string)<br/>    storage_account_name            = optional(string)<br/>    use_managed_identity            = optional(bool, true)<br/>    use_private_link                = optional(bool, false)<br/>    private_link_target_resource_id = optional(string)<br/>    private_link_subresource_name   = optional(string, "blob")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_factory_id"></a> [data\_factory\_id](#output\_data\_factory\_id) | n/a |
| <a name="output_data_factory_identity_principal_id"></a> [data\_factory\_identity\_principal\_id](#output\_data\_factory\_identity\_principal\_id) | n/a |
| <a name="output_data_factory_identity_tenant_id"></a> [data\_factory\_identity\_tenant\_id](#output\_data\_factory\_identity\_tenant\_id) | n/a |
| <a name="output_data_factory_name"></a> [data\_factory\_name](#output\_data\_factory\_name) | n/a |
| <a name="output_postgresql_private_endpoint_names"></a> [postgresql\_private\_endpoint\_names](#output\_postgresql\_private\_endpoint\_names) | PostgreSQL managed private endpoints created by the module. |
| <a name="output_sql_private_endpoint_names"></a> [sql\_private\_endpoint\_names](#output\_sql\_private\_endpoint\_names) | SQL Server managed private endpoints created by the module. |
| <a name="output_standard_storage_account_id"></a> [standard\_storage\_account\_id](#output\_standard\_storage\_account\_id) | n/a |
| <a name="output_standard_storage_account_name"></a> [standard\_storage\_account\_name](#output\_standard\_storage\_account\_name) | n/a |
