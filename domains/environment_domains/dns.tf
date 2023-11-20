data "azurerm_dns_zone" "main" {
  name                = var.zone
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_txt_record" "main" {
  for_each            = { for k in toset(var.domains) : k => k if !startswith(k, "apex") }
  name                = join(".", ["_dnsauth", "${each.key}"])
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  record {
    value = azurerm_cdn_frontdoor_custom_domain.main[each.key].validation_token
  }
}

resource "azurerm_dns_txt_record" "apex" {
  for_each            = { for k in toset(var.domains) : k => k if startswith(k, "apex") }
  name                = "_dnsauth"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  record {
    value = azurerm_cdn_frontdoor_custom_domain.main[each.key].validation_token
  }
}

# We create the CNAME record if it's not excluded and if it's not an apex
resource "azurerm_dns_cname_record" "main" {
  depends_on = [azurerm_cdn_frontdoor_route.main]
  for_each   = { for k in toset(var.domains) : k => k if !contains(var.exclude_cnames, k) && !startswith(k, "apex") }

  name                = each.key
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = azurerm_cdn_frontdoor_endpoint.main[each.key].host_name
}

resource "azurerm_dns_a_record" "main" {
  depends_on          = [azurerm_cdn_frontdoor_route.main]
  for_each            = { for k in toset(var.domains) : k => k if startswith(k, "apex") }
  name                = "@"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.main[each.key].id
}
