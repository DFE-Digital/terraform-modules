## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_statuscake"></a> [statuscake](#provider\_statuscake) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [statuscake_ssl_check.main](https://registry.terraform.io/providers/hashicorp/statuscake/latest/docs/resources/ssl_check) | resource |
| [statuscake_uptime_check.main](https://registry.terraform.io/providers/hashicorp/statuscake/latest/docs/resources/uptime_check) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_contact_groups"></a> [contact\_groups](#input\_contact\_groups) | Contact groups for the alerts | `list(string)` | `[]` | no |
| <a name="input_ssl_urls"></a> [ssl\_urls](#input\_ssl\_urls) | Set of URLs to perform SSL checks on | `list(string)` | `[]` | no |
| <a name="input_uptime_urls"></a> [uptime\_urls](#input\_uptime\_urls) | Set of URLs to perform uptime checks on | `list(string)` | `[]` | no |

## Outputs

No outputs.
