resource "azurerm_cdn_frontdoor_profile" "main" {
  for_each            = var.hosted_zone
  name                = each.value.front_door_name
  resource_group_name = each.value.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}
