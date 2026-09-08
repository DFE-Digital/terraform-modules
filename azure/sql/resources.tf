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
  name                = "${local.resource_prefix}-${var.server_name_suffix}-sql"
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
  for_each = var.private_endpoints

  name                = "${local.resource_prefix}-${each.key}-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = azurerm_mssql_server.main.id
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

resource "azurerm_mssql_database" "main" {
  for_each = var.databases

  name      = "${local.resource_prefix}-${each.value.server_name_suffix}-sql-db"
  server_id = azurerm_mssql_server.main.id

  sku_name             = var.azure_sql_sku
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

  sku_name             = var.azure_sql_sku
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
    ignore_changes = [tags]
  }
}

locals {
  allowed_ips = {
    home   = "203.0.113.10"
    office = "198.51.100.20"
  }
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each = {
    for rule in var.firewall_rules :
    rule.name => rule
  }

  name             = each.value.name
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = coalesce(each.value.start_ip_address, each.value.ip_address)
  end_ip_address   = coalesce(each.value.end_ip_address, each.value.ip_address)
}

resource "azurerm_monitor_metric_alert" "cpu" {
  # count = var.azure_enable_monitoring ? 1 : 0
  for_each = var.databases

  name                = "${azurerm_mssql_database.main[each.key].name}-cpu"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_mssql_database.main[each.key].id]

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

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_metric_alert" "storage" {
  # count = var.azure_enable_monitoring ? 1 : 0
  for_each = var.databases

  name                = "${azurerm_mssql_database.main[each.key].name}-storage"
  resource_group_name = data.azurerm_resource_group.main.name

  scopes = [
    azurerm_mssql_database.main[each.key].id
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

  lifecycle {
    ignore_changes = [tags]
  }
}
