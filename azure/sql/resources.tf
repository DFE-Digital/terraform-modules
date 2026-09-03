resource "azurerm_mssql_server" "main" {
  name                = local.azure_name
  resource_group_name = data.azurerm_resource_group.main[0].name
  location            = data.azurerm_resource_group.main[0].location

  version = var.server_version

  administrator_login          = local.database_username
  administrator_login_password = local.database_password

  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_endpoint" "sql" {
  name                = "${local.azure_name}-pe"
  location            = data.azurerm_resource_group.main[0].location
  resource_group_name = data.azurerm_resource_group.main[0].name
  subnet_id           = data.azurerm_subnet.main[0].id

  private_service_connection {
    name                           = "${local.azure_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.main[0].id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "sql"

    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.main[0].id
    ]
  }
}

resource "azurerm_mssql_database" "main" {
  count = var.create_database ? 1 : 0

  name      = local.database_name
  server_id = azurerm_mssql_server.main[0].id

  sku_name = var.azure_sql_sku

  zone_redundant = var.zone_redundant

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_mssql_database" "extra" {
  for_each = toset(local.extra_database_names)

  name      = each.value
  server_id = azurerm_mssql_server.main[0].id

  sku_name = var.azure_sql_sku
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_mssql_server.main[0].name}-cpu"
  resource_group_name = data.azurerm_resource_group.main[0].name
  scopes              = [azurerm_mssql_server.main[0].id]

  window_size = var.alert_window_size
  frequency   = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_cpu_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }
}

resource "azurerm_monitor_metric_alert" "storage" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_mssql_database.main[0].name}-storage"
  resource_group_name = data.azurerm_resource_group.main[0].name

  scopes = [
    azurerm_mssql_database.main[0].id
  ]

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_storage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }
}
