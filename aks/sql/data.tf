data "azurerm_resource_group" "main" {
  count = var.use_azure ? 1 : 0

  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

data "azurerm_subnet" "sql" {
  count = var.use_azure ? 1 : 0

  name                 = "sql-snet"
  virtual_network_name = "${var.cluster_configuration_map.resource_prefix}-vnet"
  resource_group_name  = var.cluster_configuration_map.resource_group_name
}

data "azurerm_private_dns_zone" "sql" {
  count = var.use_azure ? 1 : 0

  name                = "privatelink.database.windows.net"
  resource_group_name = "${var.cluster_configuration_map.resource_prefix}-bs-rg"
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

data "azuread_group" "sql_entra_admin" {
  count = var.entra_admin == "" ? 0 : 1

  display_name = var.entra_admin
}

#Blob Private networking
data "azurerm_virtual_network" "priv" {
  count               = local.azure_enable_backup_storage && var.azure_backup_storage_private_endpoint_enabled ? 1 : 0
  name                = "${var.cluster_configuration_map.resource_prefix}-vnet"
  resource_group_name = var.cluster_configuration_map.resource_group_name
}

data "azurerm_subnet" "priv" {
  count                = local.azure_enable_backup_storage && var.azure_backup_storage_private_endpoint_enabled ? 1 : 0
  name                 = "private-storage-snet"
  virtual_network_name = "${var.cluster_configuration_map.resource_prefix}-vnet"
  resource_group_name  = var.cluster_configuration_map.resource_group_name
}

data "azurerm_private_dns_zone" "priv" {
  count               = local.azure_enable_backup_storage && var.azure_backup_storage_private_endpoint_enabled ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "${var.cluster_configuration_map.resource_prefix}-bs-rg"
}
