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
  name                          = "${var.environment}-org"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  certificate_name_check_enabled = true
  host_name = var.host_name
  origin_host_header = var.host_name
}

# TODO: Create custom domain
# TODO: Create route
