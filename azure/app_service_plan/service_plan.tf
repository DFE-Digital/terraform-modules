resource "azurerm_service_plan" "main" {
  name                            = local.service_plan_name
  location                        = data.azurerm_resource_group.main.location
  resource_group_name             = data.azurerm_resource_group.main.name
  maximum_elastic_worker_count    = var.maximum_elastic_worker_count
  os_type                         = var.sp_os_type
  sku_name                        = var.sp_sku_name
  premium_plan_auto_scale_enabled = var.premium_plan_auto_scale_enabled
  worker_count                    = var.worker_count
  zone_balancing_enabled          = false

  lifecycle {
    ignore_changes = [tags]
  }
}
