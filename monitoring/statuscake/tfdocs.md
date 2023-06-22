## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4 |
| <a name="requirement_statuscake"></a> [statuscake](#requirement\_statuscake) | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_statuscake"></a> [statuscake](#provider\_statuscake) | >= 2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [statuscake_ssl_check.main](https://registry.terraform.io/providers/StatusCakeDev/statuscake/latest/docs/resources/ssl_check) | resource |
| [statuscake_uptime_check.main](https://registry.terraform.io/providers/StatusCakeDev/statuscake/latest/docs/resources/uptime_check) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_contact_groups"></a> [contact\_groups](#input\_contact\_groups) | Contact groups for the alerts | `list(string)` | `[]` | no |
| <a name="input_ssl_urls"></a> [ssl\_urls](#input\_ssl\_urls) | Set of URLs to perform SSL checks on | `list(string)` | `[]` | no |
| <a name="input_uptime_urls"></a> [uptime\_urls](#input\_uptime\_urls) | Set of URLs to perform uptime checks on | `list(string)` | `[]` | no |

## Outputs

No outputs.
