data "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  for_each = toset(var.domains)

  name                     = each.value
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
  tags                     = var.tags
}

# TODO: Create origin group
# TODO: Create origin
# TODO: Create custom domain
# TODO: Create route
