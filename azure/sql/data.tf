data "azurerm_resource_group" "main" {
  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

data "azurerm_monitor_diagnostic_categories" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  resource_id = azurerm_mssql_server.main.id
}

data "azurerm_resource_group" "monitoring" {
  count = var.azure_enable_monitoring ? 1 : 0

  name = "${var.azure_resource_prefix}-${var.service_short}-mn-rg"
}

data "azurerm_monitor_action_group" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                = "${var.azure_resource_prefix}-${var.service_short}"
  resource_group_name = data.azurerm_resource_group.monitoring[0].name
}
