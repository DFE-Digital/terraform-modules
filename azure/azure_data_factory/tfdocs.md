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
| [azurerm_monitor_metric_alert.failed_pipelines](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.total_entities_count](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.total_factory_size](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_window_size"></a> [alert\_window\_size](#input\_alert\_window\_size) | The period of time that is used to monitor alert activity e,g, PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly. | `string` | `"PT5M"` | no |
| <a name="input_azure_enable_monitoring"></a> [azure\_enable\_monitoring](#input\_azure\_enable\_monitoring) | Enable monitoring for Azure Data Factory. | `bool` | `true` | no |
| <a name="input_azure_failed_pipeline_threshold"></a> [azure\_failed\_pipeline\_threshold](#input\_azure\_failed\_pipeline\_threshold) | n/a | `number` | `80` | no |
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Azure prefix used to construct globally unique Data Factory names. | `string` | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment used for resource naming and tagging. | `string` | n/a | yes |
| <a name="input_git_enabled_environment"></a> [git\_enabled\_environment](#input\_git\_enabled\_environment) | Environment name for which GitHub source control should be enabled. Other environments are expected to be managed by separate GitHub workflows. | `string` | `"development"` | no |
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | GitHub repository connection for Data Factory source control. Only GitHub is supported. | <pre>object({<br/>    repository_name    = string<br/>    branch_name        = string<br/>    root_folder        = optional(string, "/adf")<br/>    publishing_enabled = optional(bool, false)<br/>    host_name          = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short service identifier used for resource naming and tagging. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_factory_id"></a> [data\_factory\_id](#output\_data\_factory\_id) | n/a |
| <a name="output_data_factory_identity_principal_id"></a> [data\_factory\_identity\_principal\_id](#output\_data\_factory\_identity\_principal\_id) | n/a |
| <a name="output_data_factory_identity_tenant_id"></a> [data\_factory\_identity\_tenant\_id](#output\_data\_factory\_identity\_tenant\_id) | n/a |
| <a name="output_data_factory_name"></a> [data\_factory\_name](#output\_data\_factory\_name) | n/a |
