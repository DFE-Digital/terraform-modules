## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.container_restarts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_pod_disruption_budget_v1.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_secret.ghcr_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_resource_group.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_enable_monitoring"></a> [azure\_enable\_monitoring](#input\_azure\_enable\_monitoring) | n/a | `bool` | `false` | no |
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | `null` | no |
| <a name="input_cluster_configuration_map"></a> [cluster\_configuration\_map](#input\_cluster\_configuration\_map) | Configuration map for the cluster | <pre>object({<br>    resource_group_name = string,<br>    resource_prefix     = string,<br>    dns_zone_prefix     = optional(string),<br>    cpu_min             = number<br>  })</pre> | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | Custom command that overwrites Docker image | `list(string)` | `[]` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Path to the docker image | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_github_personal_access_token"></a> [github\_personal\_access\_token](#input\_github\_personal\_access\_token) | Github Personal Access Token (PAT) of github\_username | `string` | `null` | no |
| <a name="input_github_username"></a> [github\_username](#input\_github\_username) | Github user authorised to access the private registry | `string` | `null` | no |
| <a name="input_is_web"></a> [is\_web](#input\_is\_web) | Whether this a web application | `bool` | `true` | no |
| <a name="input_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#input\_kubernetes\_cluster\_id) | ID of the Kubernetes cluster | `string` | `null` | no |
| <a name="input_kubernetes_config_map_name"></a> [kubernetes\_config\_map\_name](#input\_kubernetes\_config\_map\_name) | Name of the Kubernetes configuration map | `string` | n/a | yes |
| <a name="input_kubernetes_secret_name"></a> [kubernetes\_secret\_name](#input\_kubernetes\_secret\_name) | Name of the Kubernetes secrets | `string` | n/a | yes |
| <a name="input_max_memory"></a> [max\_memory](#input\_max\_memory) | Maximum memory of the instance | `string` | `"1Gi"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the application | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Current namespace | `string` | n/a | yes |
| <a name="input_probe_command"></a> [probe\_command](#input\_probe\_command) | Command for the liveness and startup probe | `list(string)` | `[]` | no |
| <a name="input_probe_path"></a> [probe\_path](#input\_probe\_path) | Path for the liveness and startup probe. The probe can be disabled by setting this to null. | `string` | `"/healthcheck"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of application instances | `number` | `1` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | `null` | no |
| <a name="input_web_external_hostnames"></a> [web\_external\_hostnames](#input\_web\_external\_hostnames) | List of external hostnames for the web application | `list(string)` | `[]` | no |
| <a name="input_web_port"></a> [web\_port](#input\_web\_port) | Port of the web application | `number` | `3000` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | n/a |
| <a name="output_probe_url"></a> [probe\_url](#output\_probe\_url) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
