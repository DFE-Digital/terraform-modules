data "azurerm_resource_group" "main" {
  name = "${local.resource_name_prefix}${var.config_short}-rg"
}

data "azurerm_resource_group" "monitoring" {
  count = var.azure_enable_monitoring ? 1 : 0

  name = "${local.resource_name_prefix}mn-rg"
}

# data "azurerm_log_analytics_workspace" "main" {
#   count = (var.azure_enable_monitoring ? 1 : 0) * (var.create_log_analytics_workspace ? 0 : 1)

#   name                = "${local.resource_name_prefix}${var.service_short}-app-service-log"
#   resource_group_name = data.azurerm_resource_group.main.name
# }
