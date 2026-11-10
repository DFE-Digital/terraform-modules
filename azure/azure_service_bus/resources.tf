locals {
  base_resource_prefix      = "${var.subscription_short}${var.env_short}"
  servicebus_namespace_name = "${local.base_resource_prefix}_${var.service_short}_${var.environment}_sbns"

  servicebus_queues = { for queue_key, queue_config in var.servicebus_queues :
    queue_key =>
    {
      name                                   = "${local.base_resource_prefix}_${var.service_short}_${var.environment}_${queue_key}"
      write_queue_duplicate_detection_window = queue_config.write_queue_duplicate_detection_window
      write_queue_max_delivery_count         = queue_config.write_queue_max_delivery_count
      write_queue_message_ttl                = queue_config.write_queue_message_ttl
      write_queue_lock_duration              = queue_config.write_queue_lock_duration
    }
  }

  azure_private_endpoint_name = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-azure-servicebus${local.name_suffix}-pe"
}

resource "azurerm_servicebus_namespace" "main" {
  name                = local.servicebus_namespace_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = var.service_bus_sku

  # Managed identity only. The API and the processor authenticate with
  # DefaultAzureCredential, never with a connection string.
  local_auth_enabled            = false
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_servicebus_queue" "queue" {
  for_each = local.servicebus_queues

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.main.id

  # Sessions keep updates for one candidate in order. The API sets SessionId
  # to the candidate ID where known, otherwise the lowercased email.
  requires_session = true

  # Duplicate detection discards a message whose MessageId was seen within
  # the window. The API hashes operation + session + payload into MessageId,
  # so an identical client retry is dropped rather than processed twice.
  requires_duplicate_detection            = true
  duplicate_detection_history_time_window = each.value.write_queue_duplicate_detection_window


  max_delivery_count                   = each.value.write_queue_max_delivery_count
  dead_lettering_on_message_expiration = true
  default_message_ttl                  = each.value.write_queue_message_ttl
  lock_duration                        = each.value.write_queue_lock_duration

  # Batched operations reduce round trips when the processor drains a session.
  batched_operations_enabled = true
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