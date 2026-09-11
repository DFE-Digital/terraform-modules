resource "azurerm_windows_function_app" "main" {
  count = var.app_type == "function" ? 1 : 0

  name                          = var.function_app_name
  location                      = data.azurerm_resource_group.main.location
  resource_group_name           = data.azurerm_resource_group.main.name
  service_plan_id               = azurerm_service_plan.main.id
  storage_account_name          = var.storage_account_name
  storage_account_access_key    = var.storage_account_access_key
  virtual_network_subnet_id     = var.subnet_id
  https_only                    = true
  public_network_access_enabled = true
  #   key_vault_reference_identity_id = "SystemAssigned"
  app_settings = merge(
    var.app_settings,
    {
      FUNCTIONS_WORKER_RUNTIME = "dotnet"
    }
  )
  identity {
    type = "SystemAssigned"
  }
  site_config {
    http2_enabled       = true
    minimum_tls_version = "1.2"
    application_stack {
      dotnet_version = try(var.application_stack.dotnet_version, null)
      java_version   = try(var.application_stack.java_version, null)
    }
  }
}

resource "azurerm_private_endpoint" "function_app_ep" {
  for_each = { for key, value in var.private_endpoints :
    key => value
  if var.app_type == "function" }

  name                = "${local.resource_name_prefix}-${each.key}-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = azurerm_windows_function_app.main[0].id
    subresource_names              = [each.value.subresource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = each.value.resource_id
    private_dns_zone_ids = [each.value.dns_zone_id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
