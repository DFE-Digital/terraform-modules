
resource "azurerm_subnet" "postgres" {
  count = var.enable_postgres ? 1 : 0

  name                 = "postgres-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.main.name
  address_prefixes     = var.postgres_subnet

  private_endpoint_network_policies = "Enabled"

  delegation {
    name = "postgres-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "sql" {
  count = var.enable_sql ? 1 : 0

  name                 = "sql-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.main.name
  address_prefixes     = var.sql_subnet

  private_endpoint_network_policies = "Enabled"

  delegation {
    name = "sql-delegation"
    service_delegation {
      name    = "Microsoft.Sql/servers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "redis" {
  count = var.enable_redis ? 1 : 0

  name                 = "redis-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.main.name
  address_prefixes     = var.redis_subnet

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "storage" {
  count = var.enable_storage ? 1 : 0

  name                 = "private-storage-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.main.name
  address_prefixes     = var.storage_subnet

  private_endpoint_network_policies = "Enabled"
}
