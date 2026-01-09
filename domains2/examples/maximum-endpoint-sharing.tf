# Example: Maximum endpoint sharing for many domains
# This example shows how to maximize endpoint sharing when you have many domains

module "domains_infrastructure" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/infrastructure_v2"
  
  front_door_name     = "multi-tenant-shared-fd"
  resource_group_name = "multi-tenant-fd-rg"
  
  # Create zones for multiple tenants/services
  hosted_zones = {
    service1 = {
      zone_name           = "service1.education.gov.uk"
      resource_group_name = "shared-dns-rg"
    }
    service2 = {
      zone_name           = "service2.education.gov.uk"
      resource_group_name = "shared-dns-rg"
    }
    service3 = {
      zone_name           = "service3.education.gov.uk"
      resource_group_name = "shared-dns-rg"
    }
    service4 = {
      zone_name           = "service4.education.gov.uk"
      resource_group_name = "shared-dns-rg"
    }
    service5 = {
      zone_name           = "service5.education.gov.uk"
      resource_group_name = "shared-dns-rg"
    }
  }
  
  azure_enable_monitoring = true
  
  tags = {
    Platform  = "SharedServices"
    ManagedBy = "PlatformTeam"
  }
}

module "domains_all_services" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/environment_domains_v2"
  
  environment             = "production"
  front_door_profile_name = module.domains_infrastructure.front_door_profile_name
  resource_group_name     = module.domains_infrastructure.front_door_resource_group_name
  
  # Use SHARED strategy to maximize endpoint efficiency
  # This allows up to 25 domains on a single endpoint
  endpoint_configuration = {
    strategy                 = "shared"
    max_domains_per_endpoint = 25  # Azure maximum
  }
  
  # Configure all service domains (up to 25 can share one endpoint)
  domains = [
    # Service 1 domains
    {
      name                = "www"
      zone                = "service1.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service1-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    },
    {
      name                = "api"
      zone                = "service1.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service1-api-prod.azurewebsites.net"
      patterns_to_match   = ["/api/*"]
      enable_caching      = false
    },
    {
      name                = "admin"
      zone                = "service1.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service1-admin-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = false
    },
    
    # Service 2 domains
    {
      name                = "www"
      zone                = "service2.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service2-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    },
    {
      name                = "api"
      zone                = "service2.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service2-api-prod.azurewebsites.net"
      patterns_to_match   = ["/api/*"]
      enable_caching      = false
    },
    
    # Service 3 domains
    {
      name                = "www"
      zone                = "service3.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service3-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    },
    {
      name                = "portal"
      zone                = "service3.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service3-portal-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    },
    
    # Service 4 domains
    {
      name                = "www"
      zone                = "service4.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service4-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    },
    {
      name                = "docs"
      zone                = "service4.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service4-docs-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
      cache_duration      = 86400  # 24 hours for documentation
    },
    
    # Service 5 domains
    {
      name                = "www"
      zone                = "service5.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service5-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    },
    {
      name                = "downloads"
      zone                = "service5.education.gov.uk"
      zone_resource_group = "shared-dns-rg"
      environment         = "production"
      origin_hostname     = "service5-downloads-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
      cache_duration      = 604800  # 7 days for static downloads
    }
    
    # ... can continue up to 25 total domains per endpoint
  ]
  
  # Shared rate limiting across all services
  rate_limit_rules = {
    "global-api-limit" = {
      domain              = "*.education.gov.uk"
      duration_in_minutes = 1
      threshold           = 10000  # 10k requests per minute across all APIs
      action              = "Log"  # Just log for now
    }
  }
  
  tags = {
    Platform    = "SharedServices"
    Environment = "Production"
    Strategy    = "MaximumSharing"
  }
}

# Output to show the efficiency gains
output "endpoint_efficiency" {
  value = {
    total_domains        = length(module.domains_all_services.custom_domains)
    total_endpoints      = length(module.domains_all_services.endpoints)
    domains_per_endpoint = length(module.domains_all_services.custom_domains) / max(length(module.domains_all_services.endpoints), 1)
    endpoint_groups      = module.domains_all_services.endpoint_groups
  }
  description = "Shows how efficiently we're using Front Door endpoints"
}

output "cost_optimization" {
  value = {
    traditional_approach = {
      front_door_profiles = "5 (one per service)"
      monthly_cost        = "£175"
    }
    optimized_approach = {
      front_door_profiles = "1 (shared)"
      monthly_cost        = "£35"
    }
    monthly_savings = "£140"
    annual_savings  = "£1,680"
  }
}