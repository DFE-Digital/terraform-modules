data "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  for_each = toset(var.domains)

  name                     = substr("${replace(each.value, ".", "-")}-${local.endpoint_zone_name}", 0, local.max_frontdoor_endpoint_name_length)
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "${var.environment}-og"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = false
  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "main" {
  name                           = "${var.environment}-org"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.main.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.host_name
  origin_host_header             = var.null_host_header == false ? var.host_name : null
}

resource "azurerm_cdn_frontdoor_custom_domain" "main" {
  for_each                 = toset(var.domains)
  name                     = replace(each.key, ".", "-")
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
  dns_zone_id              = data.azurerm_dns_zone.main.id
  host_name                = startswith(each.key, "apex") ? var.zone : "${each.key}.${var.zone}"
  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_route" "main" {
  depends_on                    = [azurerm_cdn_frontdoor_origin_group.main, azurerm_cdn_frontdoor_origin.main]
  for_each                      = toset(var.domains)
  name                          = "${var.environment}-rt"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main[each.key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main.id]
  cdn_frontdoor_rule_set_ids = concat(
    var.rule_set_ids,
    azurerm_cdn_frontdoor_rule_set.redirects[*].id,
    [azurerm_cdn_frontdoor_rule_set.security_redirects.id]
  )
  link_to_default_domain          = false
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.main[each.key].id]
  forwarding_protocol             = "HttpsOnly"
  https_redirect_enabled          = true
  patterns_to_match               = ["/*"]
  supported_protocols             = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_route" "cached" {
  for_each                      = toset(local.cached_domain_list)
  name                          = "${var.environment}-cached-rt"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main[each.key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main.id]
  cdn_frontdoor_rule_set_ids = concat(
    var.rule_set_ids,
    azurerm_cdn_frontdoor_rule_set.redirects[*].id,
    [azurerm_cdn_frontdoor_rule_set.security_redirects.id]
  )
  link_to_default_domain          = false
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.main[each.key].id]
  forwarding_protocol             = "HttpsOnly"
  https_redirect_enabled          = true
  patterns_to_match               = var.cached_paths
  supported_protocols             = ["Http", "Https"]

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "main" {
  for_each                       = toset(var.domains)
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.main[each.key].id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.main[each.key].id]
}
