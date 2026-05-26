## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_redis.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis) | resource |
| [azurerm_monitor_metric_alert.memory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [time_sleep.wait_redis_ready](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_managed_redis.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/managed_redis) | data source |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_private_dns_zone.redis_managed](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_window_size"></a> [alert\_window\_size](#input\_alert\_window\_size) | The period of time that is used to monitor alert activity e,g, PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly. | `string` | `"PT5M"` | no |
| <a name="input_azure_enable_monitoring"></a> [azure\_enable\_monitoring](#input\_azure\_enable\_monitoring) | Enable monitoring for the database server if using Azure Postgresql | `bool` | `true` | no |
| <a name="input_azure_managed_redis_sku"></a> [azure\_managed\_redis\_sku](#input\_azure\_managed\_redis\_sku) | The features and specification of the Managed Redis instance to deploy. | `string` | `"Balanced_B1"` | no |
| <a name="input_azure_maxmemory_policy"></a> [azure\_maxmemory\_policy](#input\_azure\_maxmemory\_policy) | Specifies how Redis decides which data to remove when it runs out of memory | `string` | `"AllKeysLRU"` | no |
| <a name="input_azure_memory_threshold"></a> [azure\_memory\_threshold](#input\_azure\_memory\_threshold) | n/a | `number` | `80` | no |
| <a name="input_azure_public_network_access_enabled"></a> [azure\_public\_network\_access\_enabled](#input\_azure\_public\_network\_access\_enabled) | The public network access setting for the Managed Redis instance. | `string` | `"Disabled"` | no |
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_cluster_configuration_map"></a> [cluster\_configuration\_map](#input\_cluster\_configuration\_map) | Configuration map for the Kubernetes cluster | <pre>object({<br/>    resource_group_name = string,<br/>    resource_prefix     = string,<br/>    dns_zone_prefix     = optional(string),<br/>    cpu_min             = number<br/>  })</pre> | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_db_clustering_policy"></a> [db\_clustering\_policy](#input\_db\_clustering\_policy) | The default database clustering policy specified at create time | `string` | `"NoCluster"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the instance that gets added as a suffix to the standard resource name. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Current namespace | `string` | n/a | yes |
| <a name="input_server_docker_repo"></a> [server\_docker\_repo](#input\_server\_docker\_repo) | n/a | `string` | `"ghcr.io/dfe-digital/teacher-services-cloud"` | no |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | Version of Redis server to be used in the Kubernetes container only. The version of Azure Managed Redis when deployed in Azure is managed by Redis | `string` | `"6"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_use_azure"></a> [use\_azure](#input\_use\_azure) | Whether to deploy using Azure Managed Redis service or Kubernetes. true = Azure Service, false = Kubernetes | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
