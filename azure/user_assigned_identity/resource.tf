resource "azurerm_user_assigned_identity" "app_service_identity" {    
  name                = local.user_assigned_identity_name
  resource_group_name = data.azurerm_resource_group.resource_group.name  
  location            = data.azurerm_resource_group.resource_group.location
}

locals {
  resource_name_prefix = "${var.subscription_short}${var.env_short}-${var.service_short}-"  
  resource_group_name ="${local.resource_name_prefix}${var.config_short}-rg"
  user_assigned_identity_name = "${local.resource_name_prefix}-${var.user_assigned_identity_short}-${var.environment}-${var.service_short}-id"
}

data "azurerm_resource_group" "resource_group" {
  name = local.resource_group_name
}