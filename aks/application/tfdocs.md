## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.53 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_pod_disruption_budget_v1.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_configuration_map"></a> [cluster\_configuration\_map](#input\_cluster\_configuration\_map) | Configuration map for the cluster | <pre>object({<br>    resource_group_name = string,<br>    resource_prefix     = string,<br>    dns_zone_prefix     = optional(string),<br>    cpu_min             = number<br>  })</pre> | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | Custom command that overwrites Docker image | `list(string)` | `[]` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Path to the docker image | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_is_web"></a> [is\_web](#input\_is\_web) | Whether this a web application | `bool` | `true` | no |
| <a name="input_kubernetes_config_map_name"></a> [kubernetes\_config\_map\_name](#input\_kubernetes\_config\_map\_name) | Name of the Kubernetes configuration map | `string` | n/a | yes |
| <a name="input_kubernetes_secret_name"></a> [kubernetes\_secret\_name](#input\_kubernetes\_secret\_name) | Name of the Kubernetes secrets | `string` | n/a | yes |
| <a name="input_max_memory"></a> [max\_memory](#input\_max\_memory) | Maximum memory of the instance | `string` | `"1Gi"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the application | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Current namespace | `string` | n/a | yes |
| <a name="input_probe_command"></a> [probe\_command](#input\_probe\_command) | Command for the liveness and startup probe | `list(string)` | `[]` | no |
| <a name="input_probe_path"></a> [probe\_path](#input\_probe\_path) | Path for the liveness and startup probe. The probe can be disabled by setting this to null. | `string` | `"/healthcheck"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of application instances | `number` | `1` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_web_external_hostnames"></a> [web\_external\_hostnames](#input\_web\_external\_hostnames) | List of external hostnames for the web application | `list(string)` | `[]` | no |
| <a name="input_web_port"></a> [web\_port](#input\_web\_port) | Port of the web application | `number` | `3000` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | n/a |
| <a name="output_probe_url"></a> [probe\_url](#output\_probe\_url) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
