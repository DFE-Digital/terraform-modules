locals {
  # Create a unique key for each domain
  domain_map = {
    for d in var.domains : "${d.name}-${d.zone}" => d
  }

  # Determine endpoint grouping based on strategy
  endpoint_groups = var.endpoint_configuration.strategy == "shared" ? {
    "shared-${var.environment}" = var.domains
  } : var.endpoint_configuration.strategy == "per_zone" ? {
    for zone in distinct([for d in var.domains : d.zone]) :
    "${var.environment}-${replace(zone, ".", "-")}" => [
      for d in var.domains : d if d.zone == zone
    ]
  } : { # per_environment (default)
    for env in distinct([for d in var.domains : d.environment]) :
    env => [for d in var.domains : d if d.environment == env]
  }

  # Map each domain to its endpoint
  domain_to_endpoint_map = merge([
    for ep_key, domains in local.endpoint_groups : {
      for d in domains : "${d.name}-${d.zone}" => ep_key
    }
  ]...)

  # Generate unique resource names with proper length limits
  resource_names = {
    for key, domain in local.domain_map : key => {
      # Endpoint name (max 46 chars)
      endpoint = substr(
        replace("ep-${local.domain_to_endpoint_map[key]}", ".", "-"),
        0,
        46
      )
      
      # Origin group name (max 90 chars)
      origin_group = substr(
        "og-${domain.environment}-${replace(domain.zone, ".", "-")}-${replace(domain.name, ".", "-")}",
        0,
        90
      )
      
      # Origin name (max 90 chars)
      origin = substr(
        "or-${domain.environment}-${replace(domain.zone, ".", "-")}-${replace(domain.name, ".", "-")}",
        0,
        90
      )
      
      # Route name (max 90 chars)
      route = substr(
        "rt-${domain.environment}-${replace(domain.zone, ".", "-")}-${replace(domain.name, ".", "-")}",
        0,
        90
      )
      
      # Custom domain name (max 260 chars)
      custom_domain = substr(
        "cd-${replace(domain.zone, ".", "-")}-${replace(domain.name, ".", "-")}",
        0,
        260
      )
    }
  }

  # Identify apex domains
  apex_domains = {
    for key, domain in local.domain_map : key => domain
    if startswith(domain.name, "apex")
  }

  # Identify non-apex domains
  non_apex_domains = {
    for key, domain in local.domain_map : key => domain
    if !startswith(domain.name, "apex")
  }
}