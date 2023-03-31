# terraform-modules

Repository of commonly used DfE Terraform Modules.

# DNS/records

## Description

Terraform code for managing Azure DNS records.


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
| [azurerm_dns_a_record.a_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_cname_record.cname_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) | resource |
| [azurerm_dns_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_credentials"></a> [azure\_credentials](#input\_azure\_credentials) | A json string | `any` | `null` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | n/a | `map(any)` | `{}` | no |

## Outputs

No outputs.

# DNS/zones

## Description


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
| [azurerm_dns_caa_record.caa_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record) | resource |
| [azurerm_dns_txt_record.txt_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_dns_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_credentials"></a> [azure\_credentials](#input\_azure\_credentials) | n/a | `any` | `null` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | n/a | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `any` | n/a | yes |

## Outputs

No outputs.





# Domains/**Environment_domains**

## Description


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
| [azurerm_cdn_frontdoor_custom_domain.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) | resource |
| [azurerm_cdn_frontdoor_custom_domain_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain_association) | resource |
| [azurerm_cdn_frontdoor_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_origin.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_route.cached](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_cdn_frontdoor_route.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_dns_a_record.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_cname_record.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) | resource |
| [azurerm_dns_txt_record.apex](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_dns_txt_record.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_cdn_frontdoor_profile.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/cdn_frontdoor_profile) | data source |
| [azurerm_dns_zone.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cached_paths"></a> [cached\_paths](#input\_cached\_paths) | List of path patterns such as /packs/* that front door will cache | `list(string)` | `[]` | no |
| <a name="input_domains"></a> [domains](#input\_domains) | n/a | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_front_door_name"></a> [front\_door\_name](#input\_front\_door\_name) | n/a | `any` | n/a | yes |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | n/a | `any` | n/a | yes |
| <a name="input_multiple_hosted_zones"></a> [multiple\_hosted\_zones](#input\_multiple\_hosted\_zones) | n/a | `bool` | `false` | no |
| <a name="input_null_host_header"></a> [null\_host\_header](#input\_null\_host\_header) | The origin\_host\_header for the azurerm\_cdn\_frontdoor\_origin resource will be var.host\_name (if false) or null (if true). If null then the host name from the incoming request will be used. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `any` | n/a | yes |
| <a name="input_rule_set_ids"></a> [rule\_set\_ids](#input\_rule\_set\_ids) | n/a | `list(any)` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | n/a | `any` | n/a | yes |

## Outputs

No outputs.


# Domains/**Infrastructure**


## Description


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns"></a> [dns](#module\_dns) | git::https://github.com/DFE-Digital/terraform-modules.git//dns/zones | 0.5.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_profile.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_default_records"></a> [deploy\_default\_records](#input\_deploy\_default\_records) | n/a | `bool` | `true` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | n/a | `map(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `any` | n/a | yes |

## Outputs

No outputs.

