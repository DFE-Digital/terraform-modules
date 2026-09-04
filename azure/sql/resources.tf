# Username & password

resource "random_string" "username" {
  count = var.admin_username == null ? 1 : 0

  length  = 15
  special = false
  upper   = false
}

resource "random_password" "password" {
  count = var.admin_password == null ? 1 : 0

  length  = 32
  special = true
}

resource "azurerm_mssql_server" "main" {
  name                = local.azure_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  version = var.server_version

  administrator_login          = local.database_username
  administrator_login_password = local.database_password

  public_network_access_enabled = var.public_network_access_enabled

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "sql" {
  name                = "${local.azure_name}-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${local.azure_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = var.dnszone_name
    private_dns_zone_ids = [var.dnszone_id]
  }
}

resource "azurerm_mssql_database" "main" {
  count = var.create_database ? 1 : 0

  name      = local.database_name
  server_id = azurerm_mssql_server.main.id

  sku_name = var.azure_sql_sku
  storage_account_type = var.storage_account_type

  zone_redundant = var.zone_redundant

  long_term_retention_policy {
    immutable_backups_enabled = var.enable_immutable_backups
    monthly_retention         = var.lt_ret_pol_monthly_retention
    week_of_year              = var.lt_ret_pol_week_of_year
    weekly_retention          = var.lt_ret_pol_weekly_retention
    yearly_retention          = var.lt_ret_pol_yearly_retention
  }

  short_term_retention_policy {
    backup_interval_in_hours = var.st_ret_pol_backup_interval_in_hours
    retention_days           = var.st_ret_pol_retention_days
  }

  threat_detection_policy {
    disabled_alerts            = []
    email_account_admins       = "Disabled"
    email_addresses            = []
    retention_days             = 0
    state                      = "Disabled"
    storage_account_access_key = null
    storage_endpoint           = null
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_mssql_database" "extra" {
  for_each = toset(local.extra_database_names)

  name      = each.value
  server_id = azurerm_mssql_server.main.id

  sku_name = var.azure_sql_sku
  storage_account_type = var.storage_account_type

  zone_redundant = var.zone_redundant

  long_term_retention_policy {
    immutable_backups_enabled = var.enable_immutable_backups
    monthly_retention         = var.lt_ret_pol_monthly_retention
    week_of_year              = var.lt_ret_pol_week_of_year
    weekly_retention          = var.lt_ret_pol_weekly_retention
    yearly_retention          = var.lt_ret_pol_yearly_retention
  }

  short_term_retention_policy {
    backup_interval_in_hours = var.st_ret_pol_backup_interval_in_hours
    retention_days           = var.st_ret_pol_retention_days
  }

  threat_detection_policy {
    disabled_alerts            = []
    email_account_admins       = "Disabled"
    email_addresses            = []
    retention_days             = 0
    state                      = "Disabled"
    storage_account_access_key = null
    storage_endpoint           = null
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_mssql_server.main.name}-cpu"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_server.main.id]

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
  resource_group_name = data.azurerm_resource_group.main.name

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
