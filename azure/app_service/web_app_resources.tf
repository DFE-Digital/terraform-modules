resource "azurerm_private_endpoint" "web_app_ep" {
  for_each = { for key, value in var.private_endpoints :
    key => value
  if var.app_type == "web" }

  name                = "${local.resource_name_prefix}-${each.key}-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = azurerm_windows_web_app.main[0].id
    subresource_names              = [each.value.subresource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = each.value.resource_id
    private_dns_zone_ids = [each.value.dns_zone_id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  count = (var.azure_enable_monitoring && var.create_log_analytics_workspace) ? 1 : 0

  name                = "${local.resource_name_prefix}${var.service_short}-app-service-log"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "PerGB2018"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_application_insights" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                = "${local.resource_name_prefix}${var.service_short}-${var.web_app_name}-app-service-appi"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  application_type = var.application_insights_type

  workspace_id = local.workspace_id
  # workspace_id = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].id : data.azurerm_log_analytics_workspace.main[0].id

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  logging_target_id = var.app_type == "windows_web" || var.app_type == "web" ? azurerm_windows_web_app.main[0].id : var.app_type == "linux_web" ? azurerm_linux_web_app.main[0].id : null

  slot_logging_target_ids = var.app_type == "windows_web" || var.app_type == "web" ? { for k, v in azurerm_windows_web_app_slot.main : k => v.id } : var.app_type == "linux_web" ? { for k, v in azurerm_linux_web_app_slot.main : k => v.id } : {}
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                       = "${local.resource_name_prefix}${var.web_app_name}-diag"
  target_resource_id         = local.logging_target_id
  log_analytics_workspace_id = local.workspace_id
  # log_analytics_workspace_id = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].id : data.azurerm_log_analytics_workspace.main[0].id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "slots" {
  for_each = (
    var.azure_enable_monitoring
    ? azurerm_windows_web_app_slot.main
    : {}
  )

  name                       = "${each.key}-diag"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = local.workspace_id
  # log_analytics_workspace_id = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].id : data.azurerm_log_analytics_workspace.main[0].id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
