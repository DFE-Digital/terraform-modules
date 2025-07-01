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
| [statuscake_heartbeat_check.main](https://registry.terraform.io/providers/StatusCakeDev/statuscake/latest/docs/resources/heartbeat_check) | resource |
| [statuscake_ssl_check.main](https://registry.terraform.io/providers/StatusCakeDev/statuscake/latest/docs/resources/ssl_check) | resource |
| [statuscake_uptime_check.main](https://registry.terraform.io/providers/StatusCakeDev/statuscake/latest/docs/resources/uptime_check) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confirmation"></a> [confirmation](#input\_confirmation) | Retry the check when an error is detected to avoid false positives and micro downtimes | `number` | `2` | no |
| <a name="input_contact_groups"></a> [contact\_groups](#input\_contact\_groups) | Contact groups for the alerts | `list(string)` | `[]` | no |
| <a name="input_content_matchers"></a> [content\_matchers](#input\_content\_matchers) | n/a | <pre>list(object({<br/>    matcher = string<br/>    content = string<br/>  }))</pre> | `[]` | no |
| <a name="input_heartbeat_names"></a> [heartbeat\_names](#input\_heartbeat\_names) | List of names for the heartbeat checks | `list(string)` | `[]` | no |
| <a name="input_heartbeat_period"></a> [heartbeat\_period](#input\_heartbeat\_period) | The period in seconds within which a heartbeat must be received | `number` | `600` | no |
| <a name="input_ssl_urls"></a> [ssl\_urls](#input\_ssl\_urls) | Set of URLs to perform SSL checks on | `list(string)` | `[]` | no |
| <a name="input_trigger_rate"></a> [trigger\_rate](#input\_trigger\_rate) | The number of minutes to wait before sending an alert | `number` | `0` | no |
| <a name="input_uptime_urls"></a> [uptime\_urls](#input\_uptime\_urls) | Set of URLs to perform uptime checks on | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_heartbeat_check_urls"></a> [heartbeat\_check\_urls](#output\_heartbeat\_check\_urls) | n/a |
