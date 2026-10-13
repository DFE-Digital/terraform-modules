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
| [azurerm_federated_identity_credential.github_actions_wif](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_user_assigned_identity.ga_wif](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | The short name for the environment. e.g. dv, ts, pd etc | `string` | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | The environment for the subscription. e.g. d01, t01, p01 etc | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for the resources. e.g. development, test, production etc | `string` | n/a | yes |
| <a name="input_ga_wif_immutable_repos"></a> [ga\_wif\_immutable\_repos](#input\_ga\_wif\_immutable\_repos) | Map of repos that are using immutable subject claims for WIF, with each repo mapped to its repo ID. Example:<br/>{<br/>  repo\_name\_1 = {<br/>    repo\_id = "123451"<br/>  }<br/>  repo\_name\_2 = {<br/>    repo\_id = "123452"<br/>  }<br/>} | `map(any)` | `{}` | no |
| <a name="input_ga_wif_managed_id"></a> [ga\_wif\_managed\_id](#input\_ga\_wif\_managed\_id) | A map of maps of lists containing the GitHub Actions Workload Identity Federation (WIF) managed identities. The outer map's keys are the group names, the inner map's keys are the repository names, and the inner map's values are lists of environment names. | `map(map(list(string)))` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the resources will be created. Use this variable to override the default resource group name generated from subscription\_short and subscription\_env. | `string` | `null` | no |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | The short name for the service. | `string` | n/a | yes |
| <a name="input_subscription_short"></a> [subscription\_short](#input\_subscription\_short) | The prefix for the subscription. e.g. s158, s115 etc | `string` | n/a | yes |

## Outputs

No outputs.
