
locals {
  environment   = "development"
  config_short  = "ts"
  service_short = "eprdat"
  service_name  = "education-provider-registry-data"
  #s189d01-eprdat-ts-rg
  #s189d01-eprdat-dv-rg
  resource_group_name   = "${local.azure_resource_prefix}-${local.service_short}-ts-rg"
  location              = "uksouth"
  azure_resource_prefix = "s189d01"
  key_vault_name        = "${local.azure_resource_prefix}-kv-${local.service_short}-01"
  tags = {
    product            = "Teacher services cloud"
    "Service Offering" = "Teacher services cloud"
    Environment        = "dev"
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = local.resource_group_name
}

module "data_factory" {
  source = "../../../../azure/azure_data_factory"

  environment           = local.environment
  service_short         = local.service_short
  service_name          = local.service_name
  config_short          = local.config_short
  azure_resource_prefix = local.azure_resource_prefix
  azure_enable_monitoring = false
}


output "data_factory_id" {
  value = module.data_factory.data_factory_id
}

output "data_factory_name" {
  value = module.data_factory.data_factory_name
}

output "data_factory_identity_tenant_id" {
  value = module.data_factory.data_factory_identity_tenant_id
}

output "data_factory_identity_principal_id" {
  value = module.data_factory.data_factory_identity_principal_id
}

output "data_factory_alerts" {
  value = module.data_factory.data_factory_alerts
}
