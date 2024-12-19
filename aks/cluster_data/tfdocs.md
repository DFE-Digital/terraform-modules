## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_environment"></a> [environment](#requirement\_environment) | 1.3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_environment"></a> [environment](#provider\_environment) | 1.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [environment_variables.github_actions](https://registry.terraform.io/providers/EppO/environment/1.3.5/docs/data-sources/variables) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_RBAC_enabled"></a> [azure\_RBAC\_enabled](#output\_azure\_RBAC\_enabled) | n/a |
| <a name="output_configuration_map"></a> [configuration\_map](#output\_configuration\_map) | n/a |
| <a name="output_ingress_domain"></a> [ingress\_domain](#output\_ingress\_domain) | n/a |
| <a name="output_kubelogin_args"></a> [kubelogin\_args](#output\_kubelogin\_args) | Kubelogin arguments to use configure the kubernetes provider. Allows workload identity, service principal secret and azure cli |
| <a name="output_kubernetes_client_certificate"></a> [kubernetes\_client\_certificate](#output\_kubernetes\_client\_certificate) | n/a |
| <a name="output_kubernetes_client_key"></a> [kubernetes\_client\_key](#output\_kubernetes\_client\_key) | n/a |
| <a name="output_kubernetes_cluster_ca_certificate"></a> [kubernetes\_cluster\_ca\_certificate](#output\_kubernetes\_cluster\_ca\_certificate) | n/a |
| <a name="output_kubernetes_host"></a> [kubernetes\_host](#output\_kubernetes\_host) | n/a |
| <a name="output_kubernetes_id"></a> [kubernetes\_id](#output\_kubernetes\_id) | n/a |
