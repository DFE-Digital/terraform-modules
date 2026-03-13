# Single shared Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags

  lifecycle { 
    ignore_changes = [tags] 
  }
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                = "${var.front_door_name}-log"
  location            = "uksouth"
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  tags                = var.tags

  lifecycle { 
    ignore_changes = [tags] 
  }
}

# Diagnostic categories for monitoring
data "azurerm_monitor_diagnostic_categories" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  resource_id = azurerm_cdn_frontdoor_profile.main.id
}

# Diagnostic settings for monitoring
resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                       = "${var.front_door_name}-diagnostics"
  target_resource_id         = azurerm_cdn_frontdoor_profile.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.main[0].log_category_types
    content {
      category = enabled_log.value
    }
  }

  lifecycle { 
    ignore_changes = [metric, enabled_log] 
  }
}