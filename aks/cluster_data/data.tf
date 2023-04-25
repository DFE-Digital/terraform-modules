data "azurerm_kubernetes_cluster" "main" {
  name                = "${local.configuration_map.resource_prefix}-aks"
  resource_group_name = local.configuration_map.resource_group_name
}
