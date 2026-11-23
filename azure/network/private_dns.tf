resource "azurerm_private_dns_zone" "postgres" {
  count = local.create_postgres ? 1 : 0

  name                = var.environment == var.config ? "${var.config}.internal.postgres.database.azure.com" : "${var.environment}.${var.config}.internal.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count = local.create_postgres ? 1 : 0

  name                  = azurerm_private_dns_zone.postgres[0].name
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "sql_logical_server" {
  count = local.create_sql ? 1 : 0

  # name                = var.environment == var.config ? "${var.config}.internal.sql.database.azure.com" : "${var.environment}.${var.config}.internal.sql.database.azure.com"
  name                = "privatelink.database.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_logical_server" {
  count = local.create_sql ? 1 : 0

  name                  = azurerm_private_dns_zone.sql_logical_server[0].name
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_logical_server[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "redis" {
  count = local.create_redis ? 1 : 0

  name                = "redis.azure.net"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count = local.create_redis ? 1 : 0

  name                  = "redis.azure.net"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = "redis.azure.net"
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "apps" {
  count = local.create_apps ? 1 : 0

  name                = "privatelink.azurewebsites.net"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "apps" {
  count = local.create_apps ? 1 : 0

  name                  = azurerm_private_dns_zone.apps[0].name
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.apps[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "storage" {
  count = local.create_storage ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  count = local.create_storage ? 1 : 0

  name                  = "privatelink.blob.core.windows.net"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}
