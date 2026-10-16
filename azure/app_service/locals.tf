locals {
  resource_name_prefix = "${var.subscription_short}${var.env_short}-${var.service_short}-"
  app_settings = merge(
    var.app_settings,
    var.azure_enable_monitoring ? {
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main[0].connection_string
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.main[0].instrumentation_key
    } : {}
  )
}
