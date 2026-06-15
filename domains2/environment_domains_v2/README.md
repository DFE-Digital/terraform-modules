# Environment Domains v2 Module

This module configures domains, endpoints, and routes for Azure Front Door with **intelligent endpoint sharing** to optimize resource usage and stay within Azure limits.

## Key Features

- ✅ Multiple endpoint sharing strategies (shared, per_environment, per_zone)
- ✅ Support for up to 25 domains per endpoint
- ✅ Unique resource naming to prevent conflicts
- ✅ WAF and rate limiting integration
- ✅ Redirect rules support
- ✅ Apex domain support

## Endpoint Sharing Strategies

### 1. Shared Strategy
- **Single endpoint** for all domains
- Maximum sharing (up to 25 domains)
- Best for cost optimization
- Example: All domains → 1 endpoint

### 2. Per Environment Strategy (Default)
- **One endpoint per environment**
- Balanced approach
- Good isolation between environments
- Example: prod → 1 endpoint, staging → 1 endpoint

### 3. Per Zone Strategy
- **One endpoint per DNS zone**
- Minimal sharing
- Best for zone isolation
- Example: example.com → 1 endpoint, example.org → 1 endpoint

## Usage

### Basic Configuration

```hcl
module "domains_config" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/environment_domains_v2"
  
  environment             = "production"
  front_door_profile_name = module.domains_infrastructure.front_door_profile_name
  resource_group_name     = "myapp-fd-rg"
  
  # Choose endpoint sharing strategy
  endpoint_configuration = {
    strategy                 = "per_environment"  # or "shared" or "per_zone"
    max_domains_per_endpoint = 10
  }
  
  domains = [
    {
      name                = "www"
      zone                = "example.com"
      zone_resource_group = "myapp-dns-rg"
      environment         = "production"
      origin_hostname     = "myapp-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    },
    {
      name                = "api"
      zone                = "example.com"
      zone_resource_group = "myapp-dns-rg"
      environment         = "production"
      origin_hostname     = "myapp-api-prod.azurewebsites.net"
      patterns_to_match   = ["/api/*", "/v1/*", "/v2/*"]
      enable_caching      = false
    },
    {
      name                = "apex-production"  # Apex domain
      zone                = "example.com"
      zone_resource_group = "myapp-dns-rg"
      environment         = "production"
      origin_hostname     = "myapp-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    }
  ]
}
```

### With Redirect Rules

```hcl
module "domains_config" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/environment_domains_v2"
  
  # ... other configuration ...
  
  redirect_rules = {
    "old-api" = {
      from_domain   = "api.example.com"
      from_path     = "/v1/*"
      to_domain     = "api.example.com"
      to_path       = "/v2"
      redirect_type = "PermanentRedirect"
    }
    "www-to-apex" = {
      from_domain   = "www.example.com"
      to_domain     = "example.com"
      redirect_type = "PermanentRedirect"
    }
  }
}
```

### With Rate Limiting

```hcl
module "domains_config" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/environment_domains_v2"
  
  # ... other configuration ...
  
  rate_limit_rules = {
    "api-limit" = {
      domain              = "api.example.com"
      duration_in_minutes = 1
      threshold           = 100
      action              = "Block"
    }
    "www-limit" = {
      domain              = "www.example.com"
      duration_in_minutes = 5
      threshold           = 1000
      action              = "Log"
    }
  }
}
```

## Domain Configuration Options

| Field | Description | Required | Default |
|-------|-------------|----------|---------|
| `name` | Subdomain name (use "apex-{env}" for apex domains) | Yes | - |
| `zone` | DNS zone name | Yes | - |
| `zone_resource_group` | Resource group containing the DNS zone | Yes | - |
| `environment` | Environment for this domain | Yes | - |
| `origin_hostname` | Backend hostname | Yes | - |
| `origin_host_header` | Host header to send to origin | No | Same as origin_hostname |
| `patterns_to_match` | URL patterns to match | Yes | - |
| `enable_caching` | Enable caching | No | false |
| `cache_duration` | Cache duration in seconds | No | 3600 |
| `enable_compression` | Enable compression | No | true |
| `https_redirect` | Enable HTTPS redirect | No | true |
| `exclude_cname` | Skip CNAME record creation | No | false |
| `waf_policy_id` | WAF policy to attach | No | null |
| `rule_set_ids` | Rule sets to attach | No | [] |

## Resource Naming Convention

To prevent conflicts when sharing Front Door resources, we use a hierarchical naming convention:

```
{resource_type}-{environment}-{zone}-{domain}

Examples:
- ep-production              (endpoint)
- og-prod-example-com-www    (origin group)
- rt-staging-example-org-api (route)
```

## Outputs

| Name | Description |
|------|-------------|
| `endpoints` | Map of Front Door endpoints |
| `custom_domains` | Map of custom domains with validation tokens |
| `routes` | Map of Front Door routes |
| `dns_records` | DNS records created (CNAME, A, TXT) |
| `endpoint_sharing_strategy` | The strategy used for endpoint sharing |
| `endpoint_groups` | How domains are grouped into endpoints |

## Migration from Legacy Modules

To migrate from the old `domains/environment_domains` module:

1. Deploy infrastructure_v2 module first
2. Configure domains with appropriate endpoint strategy
3. Test with non-production domains first
4. Validate certificate provisioning (can take 15-20 minutes)
5. Switch production traffic once validated

## Troubleshooting

### Certificate Validation Issues
- Ensure TXT records are created for domain validation
- Check validation_token in outputs
- Wait 15-20 minutes for automatic validation

### Endpoint Limit Issues
- Maximum 25 endpoints per Front Door profile
- Use "shared" or "per_environment" strategy to consolidate
- Monitor endpoint usage in outputs

### DNS Record Conflicts
- Check for existing CNAME/A records
- Use `exclude_cname` option if managing DNS elsewhere
- Apex domains automatically use A records instead of CNAME

## Best Practices

1. **Start with per_environment strategy** - Good balance of isolation and efficiency
2. **Use shared strategy for many domains** - When you have >10 domains
3. **Monitor endpoint usage** - Check `endpoint_groups` output
4. **Test in staging first** - Always validate in non-production
5. **Plan certificate validation time** - Allow 15-20 minutes for new domains