data "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
}
resource "azurerm_cdn_frontdoor_endpoint" "main" {
  for_each = toset(var.domains)

  name                     = "${each.value}-${local.endpoint_zone_name}"
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
  origin_host_header             = var.host_name
}

resource "azurerm_cdn_frontdoor_custom_domain" "main" {
  for_each                 = toset(var.domains)
  name                     = each.key
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
  dns_zone_id              = data.azurerm_dns_zone.main.id
  host_name                = each.key == "apex" ? "${var.zone}" : "${each.key}.${var.zone}"
  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_dns_txt_record" "main" {
  for_each = { for k in toset(var.domains) : k => k if k != "apex" }
  name                = join(".", ["_dnsauth", "${each.key}"])
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.main[each.key].validation_token
  }
}

resource "azurerm_dns_txt_record" "apex" {
  for_each = { for k in toset(var.domains) : k => k if k == "apex" }
  name                = "_dnsauth"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.main[each.key].validation_token
  }
}


resource "azurerm_dns_cname_record" "main" {
  depends_on = [azurerm_cdn_frontdoor_route.main]
  for_each = { for k in toset(var.domains) : k => k if k != "apex" }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.main[each.key].host_name
}

resource "azurerm_dns_a_record" "main" {
  depends_on          = [azurerm_cdn_frontdoor_route.main]
  for_each = { for k in toset(var.domains) : k => k if k == "apex" }
  name                = "@"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.main[each.key].id
}

resource "azurerm_cdn_frontdoor_route" "main" {
  depends_on                      = [azurerm_cdn_frontdoor_origin_group.main, azurerm_cdn_frontdoor_origin.main]
  for_each                        = toset(var.domains)
  name                            = "${var.environment}-rt"
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.main[each.key].id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids        = [azurerm_cdn_frontdoor_origin.main.id]
  cdn_frontdoor_rule_set_ids      = var.rule_set_ids
  link_to_default_domain          = false
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.main[each.key].id]
  forwarding_protocol             = "HttpsOnly"
  https_redirect_enabled          = true
  patterns_to_match               = ["/*"]
  supported_protocols             = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "main" {
  for_each                        = toset(var.domains)
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.main[each.key].id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.main[each.key].id]
}
