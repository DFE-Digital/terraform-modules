locals {
  data_factory_name             = lower(replace("${var.azure_resource_prefix}-${var.service_short}-${var.environment}-adf", "/[^a-z0-9-]/", ""))
  standard_storage_account_name = substr(lower(replace("${var.azure_resource_prefix}${var.service_short}${var.environment}adf", "/[^a-z0-9]/", "")), 0, 24)
  git_enabled                   = var.git_repository != null && var.environment == var.git_enabled_environment
  github_account_name           = "DFE-Digital"

  sql_private_endpoints = {
    for connection in var.sql_server_connections :
    connection.name => {
      target_resource_id = connection.private_link_target_resource_id
      subresource_name   = "sqlServer"
    }
    if connection.create_private_endpoint &&
    connection.private_link_target_resource_id != null
  }

  postgresql_private_endpoints = {
    for connection in var.postgresql_connections :
    connection.name => {
      target_resource_id = connection.private_link_target_resource_id
      subresource_name   = "postgresqlServer"
    }
    if connection.create_private_endpoint &&
    connection.private_link_target_resource_id != null
  }

  storage_private_endpoints = {
    for connection in var.storage_account_connections :
    connection.name => {
      target_resource_id = connection.private_link_target_resource_id
      subresource_name   = connection.private_link_subresource_name
    }
    if connection.use_private_link && connection.private_link_target_resource_id != null
  }

  sql_connection_string_secrets = {
    for connection in nonsensitive(var.sql_server_connections) :
    connection.name => connection.connection_string_secret_name
    if connection.connection_string_secret_name != null
  }

  postgresql_connection_string_secrets = {
    for connection in nonsensitive(var.postgresql_connections) :
    connection.name => connection.connection_string_secret_name
    if connection.connection_string_secret_name != null
  }

  storage_connection_string_secrets = {
    for connection in nonsensitive(var.storage_account_connections) :
    connection.name => connection.connection_string_secret_name
    if connection.connection_string_secret_name != null
  }
}

resource "azurerm_data_factory" "main" {
  name                = local.data_factory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  public_network_enabled          = true
  managed_virtual_network_enabled = true

  dynamic "github_configuration" {
    for_each = local.git_enabled ? [var.git_repository] : []

    content {
      account_name       = local.github_account_name
      repository_name    = github_configuration.value.repository_name
      branch_name        = github_configuration.value.branch_name
      root_folder        = github_configuration.value.root_folder
      publishing_enabled = github_configuration.value.publishing_enabled
      git_url            = try(github_configuration.value.host_name, null)
    }
  }
}

resource "azurerm_storage_account" "standard" {
  count = var.create_standard_storage_account ? 1 : 0

  name                            = local.standard_storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_data_factory_managed_private_endpoint" "standard_storage" {
  count = var.create_standard_storage_account ? 1 : 0

  name               = "${azurerm_data_factory.main.name}-standard-storage-pe"
  data_factory_id    = azurerm_data_factory.main.id
  target_resource_id = azurerm_storage_account.standard[0].id
  subresource_name   = "blob"
}

resource "azurerm_data_factory_managed_private_endpoint" "sql" {
  for_each = local.sql_private_endpoints

  name               = "${each.key}-private-endpoint"
  data_factory_id    = azurerm_data_factory.main.id
  target_resource_id = each.value.target_resource_id
  subresource_name   = each.value.subresource_name
}

resource "azurerm_data_factory_managed_private_endpoint" "postgresql" {
  for_each = local.postgresql_private_endpoints

  name               = "${each.key}-private-endpoint"
  data_factory_id    = azurerm_data_factory.main.id
  target_resource_id = each.value.target_resource_id
  subresource_name   = each.value.subresource_name
}

resource "azurerm_data_factory_managed_private_endpoint" "storage" {
  for_each = local.storage_private_endpoints

  name               = "${each.key}-private-endpoint"
  data_factory_id    = azurerm_data_factory.main.id
  target_resource_id = each.value.target_resource_id
  subresource_name   = each.value.subresource_name
}
