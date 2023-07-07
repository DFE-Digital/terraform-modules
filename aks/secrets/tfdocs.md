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
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secrets.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_key_vault_short"></a> [key\_vault\_short](#input\_key\_vault\_short) | Short name of the key vault | `string` | `null` | no |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_map"></a> [map](#output\_map) | n/a |
