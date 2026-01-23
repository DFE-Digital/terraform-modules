# Testing Plan for domains2 Terraform Modules

## Quick Start Summary

1. **Push branch**: `git push origin 1756-spike-domains-terraform-modules-enhancements`
2. **Create test configs**: Copy test files from this plan to technical-guidance repo
3. **Update Makefile**: Add domains2 test targets
4. **Run tests**: `make domains2-infra-plan` then `make domains2-env-plan`
5. **Validate**: Check Azure Portal and DNS resolution
6. **Cleanup**: `make domains2-env-destroy` then `make domains2-infra-destroy`

## Overview

This document outlines the testing strategy for the new `domains2` modules that enable sharing Azure Front Door profiles across multiple DNS zones. The modules are designed to reduce costs by up to 66% while maintaining all existing functionality.

## Testing Strategy

We'll use the `technical-guidance` repository as our initial test case, as it has a simpler setup with a single DNS zone, making it ideal for validating the modules work correctly before testing with multi-zone services.

## Prerequisites

1. Access to the terraform-modules repository
2. Access to the technical-guidance repository  
3. Azure permissions to create Front Door and DNS resources in test environment
4. The domains2 modules branch pushed to GitHub (branch: `1756-spike-domains-terraform-modules-enhancements`)

## Current State Analysis

### technical-guidance Repository
- **Single DNS zone**: technical-guidance.education.gov.uk
- **Single Front Door**: s189p01-techg-dom-fd
- Uses `TERRAFORM_MODULES_TAG` environment variable for version control
- Has production and review environments
- Uses Makefile-driven deployment workflow

### Key Files
- `terraform/domains/infrastructure/` - Current infrastructure module usage
- `terraform/domains/environment_domains/` - Current environment domains module usage
- `global_config/domains.sh` - Sets `TERRAFORM_MODULES_TAG=stable`
- `Makefile` - Deployment automation

## Test Implementation

### Step 1: Push domains2 Branch

```bash
cd /Users/shaheislam/work/terraform-modules
git add domains2/
git commit -m "feat: Add domains2 modules with shared Front Door support"
git push origin 1756-spike-domains-terraform-modules-enhancements
```

### Step 2: Create Test Configurations

Create parallel test directories that use the new domains2 modules:

#### File 1: `terraform/domains/infrastructure_v2_test/main.tf`

```hcl
module "domains_infrastructure" {
  source = "./vendor/modules/domains//domains2/infrastructure_v2"
  
  front_door_name     = "s189p01-techg-test-fd"  # New name for testing
  resource_group_name = "s189p01-techg-dom-rg"
  
  hosted_zones = {
    main = {
      zone_name           = "technical-guidance.education.gov.uk"
      resource_group_name = "s189p01-techg-dom-rg"
      deploy_default_records = false  # Matching current config
      caa_record_list     = []
      txt_records         = {}
    }
  }
  
  azure_enable_monitoring = false
  
  tags = {
    Service     = "TechnicalGuidance"
    Environment = "Test"
    Module      = "domains2"
  }
}
```

#### File 2: `terraform/domains/infrastructure_v2_test/terraform.tf`

```hcl
terraform {
  required_version = "= 1.6.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
  backend "azurerm" {
    container_name = "terraform-state"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
```

#### File 3: `terraform/domains/infrastructure_v2_test/variables.tf`

```hcl
variable "hosted_zone" {
  type = map(any)
  default = {}
}

variable "deploy_default_records" {
  default = false
}
```

#### File 4: `terraform/domains/environment_domains_v2_test/main.tf`

```hcl
module "domains" {
  source = "./vendor/modules/domains//domains2/environment_domains_v2"
  
  environment             = "production"
  front_door_profile_name = "s189p01-techg-test-fd"
  resource_group_name     = "s189p01-techg-dom-rg"
  
  endpoint_configuration = {
    strategy = "per_environment"  # Simple strategy for single zone
  }
  
  domains = [
    {
      name                = "apex-production"
      zone                = "technical-guidance.education.gov.uk"
      zone_resource_group = "s189p01-techg-dom-rg"
      environment         = "production"
      origin_hostname     = "technical-guidance-production.teacherservices.cloud"
      patterns_to_match   = ["/*"]
      enable_caching      = true
      subdomain          = null  # Apex domain (no subdomain)
      health_probe_path  = "/"
      health_probe_interval = 30
      health_probe_timeout  = 120
    }
  ]
  
  tags = {
    Service     = "TechnicalGuidance"
    Environment = "Production"
    Module      = "domains2"
  }
}
```

#### File 5: `terraform/domains/environment_domains_v2_test/terraform.tf`

```hcl
terraform {
  required_version = "= 1.6.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
  backend "azurerm" {
    container_name = "terraform-state"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
```

#### File 6: `terraform/domains/environment_domains_v2_test/variables.tf`

```hcl
variable "hosted_zone" {
  type = map(any)
  default = {}
}

variable "rate_limit" {
  default = null
}
```

### Step 3: Add Test Commands to Makefile

Add these test targets to the technical-guidance Makefile (after line 140 in the current Makefile):

```makefile
# Test domains2 infrastructure
domains2-infra-vendor:
	rm -rf terraform/domains/infrastructure_v2_test/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch 1756-spike-domains-terraform-modules-enhancements https://github.com/DFE-Digital/terraform-modules.git terraform/domains/infrastructure_v2_test/vendor/modules/domains

domains2-infra-init: domains composed-variables domains2-infra-vendor set-azure-account
	terraform -chdir=terraform/domains/infrastructure_v2_test init -upgrade -reconfigure \
		-backend-config=resource_group_name=${RESOURCE_GROUP_NAME} \
		-backend-config=storage_account_name=${STORAGE_ACCOUNT_NAME} \
		-backend-config=key=domains2_infrastructure_test.tfstate

domains2-infra-plan: domains2-infra-init
	terraform -chdir=terraform/domains/infrastructure_v2_test plan

domains2-infra-apply: domains2-infra-init
	terraform -chdir=terraform/domains/infrastructure_v2_test apply ${AUTO_APPROVE}

# Test domains2 environment domains
domains2-env-vendor:
	rm -rf terraform/domains/environment_domains_v2_test/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch 1756-spike-domains-terraform-modules-enhancements https://github.com/DFE-Digital/terraform-modules.git terraform/domains/environment_domains_v2_test/vendor/modules/domains

domains2-env-init: domains composed-variables domains2-env-vendor set-azure-account
	terraform -chdir=terraform/domains/environment_domains_v2_test init -upgrade -reconfigure \
		-backend-config=resource_group_name=${RESOURCE_GROUP_NAME} \
		-backend-config=storage_account_name=${STORAGE_ACCOUNT_NAME} \
		-backend-config=key=domains2_environment_test.tfstate

domains2-env-plan: domains2-env-init
	terraform -chdir=terraform/domains/environment_domains_v2_test plan

domains2-env-apply: domains2-env-init
	terraform -chdir=terraform/domains/environment_domains_v2_test apply ${AUTO_APPROVE}

# Cleanup commands
domains2-env-destroy: domains2-env-init
	terraform -chdir=terraform/domains/environment_domains_v2_test destroy ${AUTO_APPROVE}

domains2-infra-destroy: domains2-infra-init
	terraform -chdir=terraform/domains/infrastructure_v2_test destroy ${AUTO_APPROVE}
```

## Test Execution

### Phase 0: Pre-Test Verification

```bash
# Verify current setup (optional - to understand what exists)
cd /Users/shaheislam/work/technical-guidance
make domains-infra-plan  # See current infrastructure
make domains-plan CONFIG=production  # See current production config
```

### Phase 1: Infrastructure Module Testing

```bash
cd /Users/shaheislam/work/technical-guidance

# Plan infrastructure changes
make domains2-infra-plan

# Expected output should show:
# - 1 azurerm_cdn_frontdoor_profile to be created
# - 1 azurerm_dns_zone to be created/referenced
# - Optional monitoring resources if enabled

# Apply if plan looks correct
make domains2-infra-apply
```

### Phase 2: Environment Domains Module Testing

```bash
# Plan environment domains changes
make domains2-env-plan

# Expected output should show:
# - 1 azurerm_cdn_frontdoor_endpoint to be created
# - 1 azurerm_cdn_frontdoor_custom_domain to be created
# - 1 azurerm_cdn_frontdoor_route to be created
# - DNS records (A record for apex domain)

# Apply if plan looks correct
make domains2-env-apply
```

## Validation Checklist

### 1. Azure Portal Validation

- [ ] Front Door profile `s189p01-techg-test-fd` exists
- [ ] Endpoint is properly configured
- [ ] Custom domain is validated and active
- [ ] Route is correctly configured
- [ ] Origin group and origin are healthy

### 2. DNS Validation

```bash
# Check DNS resolution
nslookup technical-guidance.education.gov.uk

# Should resolve to Front Door endpoint
# Expected: *.azurefd.net address
```

### 3. Functional Testing

```bash
# Test HTTPS endpoint
curl -I https://technical-guidance.education.gov.uk

# Expected: HTTP 200 or 301 redirect
# Check headers for Front Door indicators
```

### 4. Certificate Validation

- [ ] Check Front Door managed certificate is provisioned
- [ ] Verify HTTPS is working correctly
- [ ] Check certificate expiry date

## Cleanup Process

After successful testing:

```bash
# Remove test resources in reverse order
make domains2-env-destroy
make domains2-infra-destroy

# Remove test directories
rm -rf terraform/domains/infrastructure_v2_test
rm -rf terraform/domains/environment_domains_v2_test
```

## Test Results Documentation

### Expected Outcomes

1. **Functionality**: All domains work as before
2. **Resource Efficiency**: Single Front Door profile manages the zone
3. **Cost**: For single zone, cost remains same (real savings come with multiple zones)
4. **Migration Path**: Clear path for existing services to adopt domains2

### Success Criteria

- [ ] All terraform plans execute without errors
- [ ] Resources are created successfully
- [ ] DNS resolution works correctly
- [ ] HTTPS endpoints are accessible
- [ ] No disruption to existing services
- [ ] Clean rollback if needed

## Next Steps

### For Single-Zone Services (like technical-guidance)

1. Document migration process
2. Plan production migration window
3. Update service documentation

### For Multi-Zone Services (like access-your-teaching-qualifications)

1. Create test configuration with multiple zones
2. Validate endpoint sharing strategies
3. Calculate actual cost savings
4. Plan phased migration approach

## Advanced Testing Scenarios

### Scenario A: Testing Endpoint Sharing Strategies

Modify the `endpoint_configuration` to test different strategies:

```hcl
# Maximum sharing
endpoint_configuration = {
  strategy = "shared"
  max_domains_per_endpoint = 25
}

# Per-zone sharing
endpoint_configuration = {
  strategy = "per_zone"
}
```

### Scenario B: Testing with Multiple Domains

Add more domains to the configuration:

```hcl
domains = [
  {
    name = "apex-production"
    # ... configuration
  },
  {
    name = "www"
    # ... configuration
  },
  {
    name = "api"
    # ... configuration
  }
]
```

### Scenario C: Testing Rate Limiting

Add rate limiting configuration:

```hcl
rate_limit_rules = {
  "global-limit" = {
    domain              = "technical-guidance.education.gov.uk"
    duration_in_minutes = 1
    threshold           = 1000
    action              = "Log"
  }
}
```

## Troubleshooting

### Common Issues and Solutions

1. **DNS Zone Already Exists**
   - Solution: Use data source instead of resource
   - Or: Import existing zone into state

2. **Front Door Name Conflicts**
   - Solution: Use unique test names
   - Clean up old test resources

3. **Certificate Validation Delays**
   - Solution: Wait 15-20 minutes for automatic validation
   - Check TXT records are created correctly

4. **State File Conflicts**
   - Solution: Use separate state files for test
   - Ensure backend configuration is correct

## Support and Questions

For questions or issues:
1. Check the domains2 README files
2. Review Azure Front Door documentation
3. Check terraform-modules PR discussions
4. Contact the platform team

---

*Last Updated: January 2025*
*Version: 1.0*
*Status: Ready for Testing*