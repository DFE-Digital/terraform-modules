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
| [azurerm_private_dns_zone.postgres](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.postgres](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_subnet.postgres](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Standard resource prefix. Usually s189t01 (test) or s189p01 (production) | `string` | n/a | yes |
| <a name="input_config"></a> [config](#input\_config) | Long name of the environment configuration, e.g. development, staging, production... | `string` | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the environment configuration, e.g. dv, st, pd... | `string` | n/a | yes |
| <a name="input_enable_postgres"></a> [enable\_postgres](#input\_enable\_postgres) | n/a | `bool` | `false` | no |
| <a name="input_enable_redis"></a> [enable\_redis](#input\_enable\_redis) | n/a | `bool` | `false` | no |
| <a name="input_enable_storage"></a> [enable\_storage](#input\_enable\_storage) | n/a | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the deployed environment in AKS | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"UK South"` | no |
| <a name="input_postgres_subnet"></a> [postgres\_subnet](#input\_postgres\_subnet) | n/a | `list` | <pre>[<br/>  "10.2.0.0/18"<br/>]</pre> | no |
| <a name="input_redis_subnet"></a> [redis\_subnet](#input\_redis\_subnet) | n/a | `list` | <pre>[<br/>  "10.2.64.0/18"<br/>]</pre> | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Full name of the service. Lowercase and hyphen separated | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name to identify the service. Up to 6 characters. | `string` | n/a | yes |
| <a name="input_storage_subnet"></a> [storage\_subnet](#input\_storage\_subnet) | n/a | `list` | <pre>[<br/>  "10.2.128.0/18"<br/>]</pre> | no |
| <a name="input_vnet_address"></a> [vnet\_address](#input\_vnet\_address) | n/a | `list` | <pre>[<br/>  "10.0.0.0/12"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_postgres_privdns_id"></a> [postgres\_privdns\_id](#output\_postgres\_privdns\_id) | Connection URLs for additional PostgreSQL databases |
| <a name="output_postgres_privdns_name"></a> [postgres\_privdns\_name](#output\_postgres\_privdns\_name) | Connection URLs for additional PostgreSQL databases |
| <a name="output_postgres_subnet"></a> [postgres\_subnet](#output\_postgres\_subnet) | Connection URLs for additional PostgreSQL databases |
| <a name="output_redis_privdns_id"></a> [redis\_privdns\_id](#output\_redis\_privdns\_id) | Connection URLs for additional PostgreSQL databases |
| <a name="output_redis_privdns_name"></a> [redis\_privdns\_name](#output\_redis\_privdns\_name) | Connection URLs for additional PostgreSQL databases |
| <a name="output_redis_subnet"></a> [redis\_subnet](#output\_redis\_subnet) | Connection URLs for additional PostgreSQL databases |
| <a name="output_storage_privdns_id"></a> [storage\_privdns\_id](#output\_storage\_privdns\_id) | Connection URLs for additional PostgreSQL databases |
| <a name="output_storage_privdns_name"></a> [storage\_privdns\_name](#output\_storage\_privdns\_name) | Connection URLs for additional PostgreSQL databases |
| <a name="output_storage_subnet"></a> [storage\_subnet](#output\_storage\_subnet) | Connection URLs for additional PostgreSQL databases |
