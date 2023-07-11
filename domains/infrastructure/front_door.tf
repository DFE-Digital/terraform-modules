resource "azurerm_cdn_frontdoor_profile" "main" {
  for_each            = var.hosted_zone
  name                = each.value.front_door_name
  resource_group_name = each.value.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags

  lifecycle { ignore_changes = [tags] }
}

data "azurerm_monitor_diagnostic_categories" "main" {
  for_each = var.azure_enable_monitoring ? var.hosted_zone : {}

  resource_id = azurerm_cdn_frontdoor_profile.main[each.key].id
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  for_each = var.azure_enable_monitoring ? var.hosted_zone : {}

  name                       = "${each.value.front_door_name}-diagnostics"
  target_resource_id         = azurerm_cdn_frontdoor_profile.main[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[each.key].id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.main[each.key].log_category_types
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  for_each = var.azure_enable_monitoring ? var.hosted_zone : {}

  name                = "${each.value.front_door_name}-log"
  location            = "uksouth"
  resource_group_name = each.value.resource_group_name
  sku                 = "PerGB2018"
}
