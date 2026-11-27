# Infrastructure v2 Module

This module creates a **single shared Azure Front Door profile** that can serve multiple DNS zones, replacing the expensive pattern of creating one Front Door per zone.

## Key Features

- ✅ Single Front Door profile for all zones (66% cost reduction)
- ✅ Multiple DNS zone management
- ✅ Centralized monitoring and diagnostics
- ✅ Default security records (CAA, SPF, DMARC)
- ✅ Cost-optimized architecture

## Usage

```hcl
module "domains_infrastructure" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/infrastructure_v2"
  
  front_door_name     = "myapp-shared-fd"
  resource_group_name = "myapp-fd-rg"
  
  hosted_zones = {
    production = {
      zone_name           = "example.com"
      resource_group_name = "myapp-dns-rg"
      deploy_default_records = true
      caa_record_list     = ["globalsign.com", "digicert.com"]
    }
    staging = {
      zone_name           = "staging.example.org"
      resource_group_name = "myapp-dns-rg"
      deploy_default_records = true
    }
    development = {
      zone_name           = "dev.example.net"
      resource_group_name = "myapp-dns-rg"
      deploy_default_records = false  # Skip default records for dev
    }
  }
  
  azure_enable_monitoring = true
  
  tags = {
    Environment = "Production"
    Service     = "MyApp"
    ManagedBy   = "Terraform"
  }
}
```

## Cost Savings

| Setup | Monthly Cost | Savings |
|-------|--------------|---------|
| Old (3 Front Doors) | ~£105 | - |
| New (1 Front Door) | ~£35 | £70 (66%) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `front_door_name` | Name of the shared Front Door profile | `string` | - | yes |
| `hosted_zones` | Map of DNS zones to manage | `map(object)` | - | yes |
| `resource_group_name` | Resource group for Front Door resources | `string` | - | yes |
| `azure_enable_monitoring` | Enable Azure monitoring and diagnostics | `bool` | `false` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `front_door_profile_id` | The ID of the Front Door profile |
| `front_door_profile_name` | The name of the Front Door profile |
| `front_door_resource_group_name` | The resource group name of the Front Door profile |
| `dns_zones` | Map of DNS zones with their details |
| `log_analytics_workspace_id` | The ID of the Log Analytics workspace (if monitoring is enabled) |

## Migration from Legacy Modules

To migrate from the old `domains/infrastructure` module:

1. Deploy this module alongside the existing infrastructure
2. Use the `environment_domains_v2` module to configure domains
3. Wait for certificate validation
4. Switch DNS records to the new Front Door
5. Decommission old Front Door profiles

## Monitoring

When `azure_enable_monitoring` is enabled, Front Door logs are available in the Log Analytics workspace. Example query:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "FrontdoorAccessLog"
| where isReceivedFromClient_b == true
| where toint(httpStatusCode_s) >= 400
| extend ParsedUrl = parseurl(requestUri_s)
| summarize RequestCount = count() by Host = tostring(ParsedUrl.Host), Path = tostring(ParsedUrl.Path), StatusCode = httpStatusCode_s
| order by RequestCount desc
```