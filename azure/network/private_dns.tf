resource "azurerm_private_dns_zone" "postgres" {
  count = var.enable_postgres ? 1 : 0

  name                = var.environment == var.config ? "${var.config}.internal.postgres.database.azure.com" : "${var.environment}.${var.config}.internal.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count = var.enable_postgres ? 1 : 0

  name                  = azurerm_private_dns_zone.postgres[0].name
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "sql_logical_server" {
  count = var.enable_sql_logical_server ? 1 : 0

  name                = var.environment == var.config ? "${var.config}.internal.postgres.database.azure.com" : "${var.environment}.${var.config}.internal.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_logical_server" {
  count = var.enable_sql_logical_server ? 1 : 0

  name                  = "internal.postgres.database.azure.com"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = "internal.postgres.database.azure.com"
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "redis" {
  count = var.enable_redis ? 1 : 0

  name                = "redis.azure.net"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count = var.enable_redis ? 1 : 0

  name                  = "redis.azure.net"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = "redis.azure.net"
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone" "storage" {
  count = var.enable_storage ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  count = var.enable_storage ? 1 : 0

  name                  = "privatelink.blob.core.windows.net"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}
