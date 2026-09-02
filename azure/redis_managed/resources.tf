locals {
  name_suffix = var.name != null ? "-${var.name}" : ""

  azure_name                  = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-managed-redis${local.name_suffix}"
  azure_private_endpoint_name = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-managed-redis${local.name_suffix}-pe"
  azure_enable_monitoring     = var.azure_enable_monitoring

  alert_frequency_map = {
    PT5M  = "PT1M"
    PT15M = "PT1M"
    PT30M = "PT1M"
    PT1H  = "PT1M"
    PT6H  = "PT5M"
    PT12H = "PT5M"
  }
  alert_frequency = local.alert_frequency_map[var.alert_window_size]
}

# Azure Managed Redis

resource "azurerm_managed_redis" "main" {
  name                      = local.azure_name
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  sku_name                  = var.azure_managed_redis_sku
  high_availability_enabled = var.managed_redis_high_availability
  public_network_access     = var.azure_public_network_access_enabled

  default_database {
    access_keys_authentication_enabled = true
    eviction_policy                    = var.azure_maxmemory_policy
    clustering_policy                  = var.db_clustering_policy
  }

  lifecycle {
    ignore_changes = [tags]
  }

  timeouts {
    create = "1h"
    update = "1h"
  }
}

# Required Private Endpoint

resource "azurerm_private_endpoint" "main" {
  name                = local.azure_private_endpoint_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = var.dnszone_name
    private_dns_zone_ids = [var.dnszone_id]
  }

  private_service_connection {
    name                           = local.azure_private_endpoint_name
    private_connection_resource_id = azurerm_managed_redis.main.id
    is_manual_connection           = false
    subresource_names              = ["redisEnterprise"]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Alert if high memory usage

resource "azurerm_monitor_metric_alert" "memory" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_managed_redis.main.name}-memory"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_managed_redis.main.id]
  description         = "Action will be triggered when memory use is greater than ${var.azure_memory_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.Cache/redisEnterprise"
    metric_name      = "usedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_memory_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
    webhook_properties = {
      target_channels = var.service_short
      environment     = var.environment
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
