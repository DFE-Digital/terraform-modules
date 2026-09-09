# Example: Multiple DNS zones with a single shared Front Door profile
# This example shows how to save ~66% on Front Door costs by sharing one profile across multiple zones

# Step 1: Create the shared infrastructure (DNS zones + Front Door profile)
module "domains_infrastructure" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/infrastructure_v2"
  
  front_door_name     = "myservice-shared-fd"
  resource_group_name = "myservice-fd-rg"
  
  # Configure multiple DNS zones
  hosted_zones = {
    production = {
      zone_name           = "myservice.education.gov.uk"
      resource_group_name = "myservice-dns-rg"
      deploy_default_records = true
      caa_record_list     = ["globalsign.com", "digicert.com", "letsencrypt.org"]
    }
    staging = {
      zone_name           = "staging.myservice.education.gov.uk"
      resource_group_name = "myservice-dns-rg"
      deploy_default_records = true
    }
    development = {
      zone_name           = "dev.myservice.education.gov.uk"
      resource_group_name = "myservice-dns-rg"
      deploy_default_records = true
    }
  }
  
  # Enable monitoring for production
  azure_enable_monitoring = true
  
  tags = {
    Service     = "MyService"
    Environment = "All"
    ManagedBy   = "Terraform"
    CostCenter  = "12345"
  }
}

# Step 2: Configure domains and routing for production environment
module "domains_production" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/environment_domains_v2"
  
  environment             = "production"
  front_door_profile_name = module.domains_infrastructure.front_door_profile_name
  resource_group_name     = module.domains_infrastructure.front_door_resource_group_name
  
  # Use per-environment strategy for good isolation
  endpoint_configuration = {
    strategy                 = "per_environment"
    max_domains_per_endpoint = 10
  }
  
  domains = [
    {
      name                = "www"
      zone                = "myservice.education.gov.uk"
      zone_resource_group = "myservice-dns-rg"
      environment         = "production"
      origin_hostname     = "myservice-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
      cache_duration      = 7200  # 2 hours
    },
    {
      name                = "api"
      zone                = "myservice.education.gov.uk"
      zone_resource_group = "myservice-dns-rg"
      environment         = "production"
      origin_hostname     = "myservice-api-prod.azurewebsites.net"
      origin_host_header  = "api.myservice.education.gov.uk"
      patterns_to_match   = ["/api/*", "/v1/*", "/v2/*"]
      enable_caching      = false  # Don't cache API responses
    },
    {
      name                = "apex-production"
      zone                = "myservice.education.gov.uk"
      zone_resource_group = "myservice-dns-rg"
      environment         = "production"
      origin_hostname     = "myservice-prod.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
    }
  ]
  
  # Redirect rules for production
  redirect_rules = {
    "old-api-redirect" = {
      from_domain   = "api.myservice.education.gov.uk"
      from_path     = "/v1/*"
      to_domain     = "api.myservice.education.gov.uk"
      to_path       = "/v2"
      redirect_type = "PermanentRedirect"
    }
  }
  
  # Rate limiting for production API
  rate_limit_rules = {
    "api-rate-limit" = {
      domain              = "api.myservice.education.gov.uk"
      duration_in_minutes = 1
      threshold           = 1000  # 1000 requests per minute
      action              = "Block"
    }
  }
  
  tags = {
    Service     = "MyService"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Step 3: Configure domains for staging environment
module "domains_staging" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains2/environment_domains_v2"
  
  environment             = "staging"
  front_door_profile_name = module.domains_infrastructure.front_door_profile_name
  resource_group_name     = module.domains_infrastructure.front_door_resource_group_name
  
  endpoint_configuration = {
    strategy                 = "per_environment"
    max_domains_per_endpoint = 10
  }
  
  domains = [
    {
      name                = "www"
      zone                = "staging.myservice.education.gov.uk"
      zone_resource_group = "myservice-dns-rg"
      environment         = "staging"
      origin_hostname     = "myservice-staging.azurewebsites.net"
      patterns_to_match   = ["/*"]
      enable_caching      = true
      cache_duration      = 600  # 10 minutes for staging
    },
    {
      name                = "api"
      zone                = "staging.myservice.education.gov.uk"
      zone_resource_group = "myservice-dns-rg"
      environment         = "staging"
      origin_hostname     = "myservice-api-staging.azurewebsites.net"
      patterns_to_match   = ["/api/*", "/v1/*", "/v2/*"]
      enable_caching      = false
    }
  ]
  
  tags = {
    Service     = "MyService"
    Environment = "Staging"
    ManagedBy   = "Terraform"
  }
}

# Outputs to verify the configuration
output "front_door_endpoints" {
  value = {
    production = module.domains_production.endpoints
    staging    = module.domains_staging.endpoints
  }
}

output "cost_savings" {
  value = {
    old_setup_monthly_cost = "£105 (3 Front Door profiles)"
    new_setup_monthly_cost = "£35 (1 Front Door profile)"
    monthly_savings        = "£70"
    annual_savings         = "£840"
  }
}