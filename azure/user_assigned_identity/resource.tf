locals {  
  resource_group_name ="${var.subscription_short}${var.env_short}-${var.service_short}-${var.config_short}-rg"
  user_assigned_identity_name = "${var.subscription_short}${var.env_short}-${var.service_short}-${var.config_short}-${var.user_assigned_identity_short}-id"
}

resource "azurerm_user_assigned_identity" "app_service_identity" {    
  name                = local.user_assigned_identity_name
  resource_group_name = data.azurerm_resource_group.resource_group.name  
  location            = data.azurerm_resource_group.resource_group.location
}

data "azurerm_resource_group" "resource_group" {
  name = local.resource_group_name
}