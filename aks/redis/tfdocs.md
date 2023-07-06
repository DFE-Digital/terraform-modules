## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.53 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.53 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.memory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_redis_cache.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group) | data source |
| [azurerm_private_dns_zone.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.monitoring](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_capacity"></a> [azure\_capacity](#input\_azure\_capacity) | n/a | `number` | `1` | no |
| <a name="input_azure_enable_monitoring"></a> [azure\_enable\_monitoring](#input\_azure\_enable\_monitoring) | n/a | `bool` | `true` | no |
| <a name="input_azure_family"></a> [azure\_family](#input\_azure\_family) | n/a | `string` | `"C"` | no |
| <a name="input_azure_maxmemory_policy"></a> [azure\_maxmemory\_policy](#input\_azure\_maxmemory\_policy) | n/a | `string` | `"allkeys-lru"` | no |
| <a name="input_azure_memory_threshold"></a> [azure\_memory\_threshold](#input\_azure\_memory\_threshold) | n/a | `number` | `60` | no |
| <a name="input_azure_minimum_tls_version"></a> [azure\_minimum\_tls\_version](#input\_azure\_minimum\_tls\_version) | n/a | `string` | `"1.2"` | no |
| <a name="input_azure_patch_schedule"></a> [azure\_patch\_schedule](#input\_azure\_patch\_schedule) | n/a | <pre>list(object({<br>    day_of_week        = string,<br>    start_hour_utc     = optional(number),<br>    maintenance_window = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_azure_public_network_access_enabled"></a> [azure\_public\_network\_access\_enabled](#input\_azure\_public\_network\_access\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_azure_resource_prefix"></a> [azure\_resource\_prefix](#input\_azure\_resource\_prefix) | Prefix of Azure resources for the service | `string` | n/a | yes |
| <a name="input_azure_sku_name"></a> [azure\_sku\_name](#input\_azure\_sku\_name) | n/a | `string` | `"Standard"` | no |
| <a name="input_cluster_configuration_map"></a> [cluster\_configuration\_map](#input\_cluster\_configuration\_map) | Configuration map for the cluster | <pre>object({<br>    resource_group_name = string,<br>    resource_prefix     = string,<br>    dns_zone_prefix     = optional(string),<br>    cpu_min             = number<br>  })</pre> | n/a | yes |
| <a name="input_config_short"></a> [config\_short](#input\_config\_short) | Short name of the configuration | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Current application environment | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the instance | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Current namespace | `string` | n/a | yes |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | Version of Redis server | `string` | `"6"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | n/a | yes |
| <a name="input_service_short"></a> [service\_short](#input\_service\_short) | Short name of the service | `string` | n/a | yes |
| <a name="input_use_azure"></a> [use\_azure](#input\_use\_azure) | Whether to deploy using Azure Redis Cache service | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
