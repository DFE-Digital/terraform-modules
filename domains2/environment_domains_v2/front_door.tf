# Data source for the Front Door profile
data "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_profile_name
  resource_group_name = var.resource_group_name
}

# Create endpoints based on sharing strategy
resource "azurerm_cdn_frontdoor_endpoint" "main" {
  for_each = local.endpoint_groups

  name                     = local.resource_names[keys(local.domain_map)[0]].endpoint
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
  tags                     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create origin groups for each domain
resource "azurerm_cdn_frontdoor_origin_group" "main" {
  for_each = local.domain_map

  name                     = local.resource_names[each.key].origin_group
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  lifecycle {
    ignore_changes = [load_balancing, health_probe]
  }
}

# Create origins for each domain
resource "azurerm_cdn_frontdoor_origin" "main" {
  for_each = local.domain_map

  name                           = local.resource_names[each.key].origin
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main[each.key].id
  enabled                        = true

  certificate_name_check_enabled = true
  host_name                      = each.value.origin_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header            = coalesce(each.value.origin_host_header, each.value.origin_hostname)
  priority                       = 1
  weight                         = 1000
}

# Create custom domains
resource "azurerm_cdn_frontdoor_custom_domain" "main" {
  for_each = local.domain_map

  name                     = local.resource_names[each.key].custom_domain
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id

  dns_zone_id = data.azurerm_dns_zone.zones[each.value.zone].id
  host_name = startswith(each.value.name, "apex") ? each.value.zone : "${each.value.name}.${each.value.zone}"

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

# Create routes for each domain
resource "azurerm_cdn_frontdoor_route" "main" {
  for_each = local.domain_map

  name                          = local.resource_names[each.key].route
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main[local.domain_to_endpoint_map[each.key]].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main[each.key].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main[each.key].id]

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = each.value.https_redirect
  patterns_to_match      = each.value.patterns_to_match
  supported_protocols    = ["Http", "Https"]
  
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.main[each.key].id]
  link_to_default_domain           = false

  dynamic "cache" {
    for_each = each.value.enable_caching ? [1] : []
    content {
      compression_enabled           = each.value.enable_compression
      query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
      query_strings                 = ["v", "version", "timestamp"]
      content_types_to_compress = [
        "text/html",
        "text/css",
        "text/javascript",
        "text/plain",
        "application/javascript",
        "application/json",
        "application/xml"
      ]
    }
  }

  # Attach WAF policy if specified
  cdn_frontdoor_firewall_policy_id = each.value.waf_policy_id

  # Attach rule sets if specified
  cdn_frontdoor_rule_set_ids = each.value.rule_set_ids
}

# Associate custom domains with routes
resource "azurerm_cdn_frontdoor_custom_domain_association" "main" {
  for_each = local.domain_map

  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.main[each.key].id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.main[each.key].id]
}