locals {
  resource_name_prefix = "${var.subscription_short}${var.env_short}-${var.service_short}-"
  workspace_id         = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].id : var.log_analytics_workspace_id

  app_settings = merge(
    var.app_settings,
    var.azure_enable_monitoring ? {
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main[0].connection_string
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.main[0].instrumentation_key
    } : {}
  )

  base_app_settings = merge(
    var.app_settings,
    var.azure_enable_monitoring ? {
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main[0].connection_string
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.main[0].instrumentation_key
    } : {}
  )

  effective_app_settings = merge(
    local.base_app_settings,
    try(var.environment_app_settings[var.web_app_name], {})
  )

  slot_environment_settings = {
    for slot_name in keys(var.slots) :
    slot_name => try(
      var.environment_slots[slot_name].app_settings,
      {}
    )
  }
}
