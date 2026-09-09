
locals {
  environment           = "development"
  service_short         = "eprdat"
  resource_group_name   = "${local.azure_resource_prefix}-${local.service_short}-ts-rg"
  location              = "uksouth"
  azure_resource_prefix = "s189d01"
  key_vault_name        = "${local.azure_resource_prefix}-kv-${local.service_short}-01"
  tags = {
    product = "Teacher services cloud"
    "Service Offering" = "Teacher services cloud"
    Environment = "Dev"
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name     = local.resource_group_name  
}

resource "azurerm_key_vault" "main" {
  name                       = local.key_vault_name
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = data.azurerm_resource_group.main.name
  rbac_authorization_enabled = false

  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

module "data_factory" {
  source = "../../../../aks/azure_data_factory"

  environment             = local.environment
  service_short           = local.service_short
  azure_resource_prefix   = local.azure_resource_prefix
  resource_group_name     = local.resource_group_name
  location                = local.location
  key_vault_name          = local.key_vault_name  

  git_repository = {    
    repository_name = "education-provider-registry-data"
    branch_name     = "2841-adf-test-collab"
    root_folder     = "/adf"
    publishing_enabled = true
    host_name = "https://github.com"
  }



  depends_on = [
    data.azurerm_resource_group.main,
    azurerm_key_vault.main,
  ]
}
