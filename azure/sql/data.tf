data "azurerm_private_dns_zone" "main" {
  name                = "privatelink.database.windows.net"
  resource_group_name = "${var.cluster_configuration_map.resource_prefix}-bs-rg"
}

data "azurerm_monitor_diagnostic_categories" "main" {
  count = var.azure_enable_monitoring ? 1 : 0

  resource_id = azurerm_mssql_server.main[0].id
}
