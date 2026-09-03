# Data sources for DNS zones
data "azurerm_dns_zone" "zones" {
  for_each = toset([for d in var.domains : d.zone])

  name                = each.value
  resource_group_name = [for d in var.domains : d.zone_resource_group if d.zone == each.value][0]
}

# TXT records for domain validation (non-apex domains)
resource "azurerm_dns_txt_record" "validation" {
  for_each = local.non_apex_domains

  name                = "_dnsauth.${each.value.name}"
  zone_name           = data.azurerm_dns_zone.zones[each.value.zone].name
  resource_group_name = each.value.zone_resource_group
  ttl                 = 300

  record {
    value = azurerm_cdn_frontdoor_custom_domain.main[each.key].validation_token
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# TXT records for domain validation (apex domains)
resource "azurerm_dns_txt_record" "validation_apex" {
  for_each = local.apex_domains

  name                = "_dnsauth"
  zone_name           = data.azurerm_dns_zone.zones[each.value.zone].name
  resource_group_name = each.value.zone_resource_group
  ttl                 = 300

  record {
    value = azurerm_cdn_frontdoor_custom_domain.main[each.key].validation_token
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# CNAME records for non-apex domains
resource "azurerm_dns_cname_record" "main" {
  for_each = {
    for key, domain in local.non_apex_domains : key => domain
    if !domain.exclude_cname
  }

  name                = each.value.name
  zone_name           = data.azurerm_dns_zone.zones[each.value.zone].name
  resource_group_name = each.value.zone_resource_group
  ttl                 = 300
  record              = azurerm_cdn_frontdoor_endpoint.main[local.domain_to_endpoint_map[each.key]].host_name

  depends_on = [azurerm_cdn_frontdoor_route.main]

  lifecycle {
    ignore_changes = [tags]
  }
}

# A records for apex domains
resource "azurerm_dns_a_record" "apex" {
  for_each = local.apex_domains

  name                = "@"
  zone_name           = data.azurerm_dns_zone.zones[each.value.zone].name
  resource_group_name = each.value.zone_resource_group
  ttl                 = 300
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.main[local.domain_to_endpoint_map[each.key]].id

  depends_on = [azurerm_cdn_frontdoor_route.main]

  lifecycle {
    ignore_changes = [tags]
  }
}