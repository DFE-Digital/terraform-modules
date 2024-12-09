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
| [azurerm_dns_caa_record.caa_record_list](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record) | resource |
| [azurerm_dns_caa_record.caa_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record) | resource |
| [azurerm_dns_txt_record.txt_record_list](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_dns_txt_record.txt_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_dns_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | List of zones and their properties. See [README](readme.md) for details. | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure resource tags. Deprecated: set tags at resource group level | `any` | `null` | no |

## Outputs

No outputs.
