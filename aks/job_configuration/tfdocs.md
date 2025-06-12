## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_job.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arguments"></a> [arguments](#input\_arguments) | list of required docker image arguments for k8s job to run | `list(string)` | <pre>[<br/>  "exec",<br/>  "rails",<br/>  "db:prepare"<br/>]</pre> | no |
| <a name="input_commands"></a> [commands](#input\_commands) | list of required docker image commands for k8s job to run | `list(string)` | <pre>[<br/>  "bundle"<br/>]</pre> | no |
| <a name="input_config_map_ref"></a> [config\_map\_ref](#input\_config\_map\_ref) | formerly: module.application\_configuration.kubernetes\_config\_map\_name | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | formerly: module.cluster\_data.configuration\_map.cpu\_min | `string` | n/a | yes |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Docker image to be used for this job | `any` | n/a | yes |
| <a name="input_enable_logit"></a> [enable\_logit](#input\_enable\_logit) | boolean for enabling Logit | `string` | `"false"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where this app is deployed. Usually test or production | `any` | n/a | yes |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | name handle for k8s job | `string` | `"migration"` | no |
| <a name="input_max_memory"></a> [max\_memory](#input\_max\_memory) | Maximum memory of the instance | `string` | `"1Gi"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | AKS namespace where this app is deployed | `any` | n/a | yes |
| <a name="input_secret_ref"></a> [secret\_ref](#input\_secret\_ref) | formerly: module.application\_configuration.kubernetes\_secret\_name | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service. Usually the same as the repo name | `any` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Create and update timeout for job | `string` | `"15m"` | no |

## Outputs

No outputs.
