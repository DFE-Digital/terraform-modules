resource "azurerm_windows_web_app" "main" {
  count = var.app_type == "web" ? 1 : 0

  name                          = "${local.resource_name_prefix}${var.web_app_name}-wa"
  location                      = data.azurerm_resource_group.main.location
  resource_group_name           = data.azurerm_resource_group.main.name
  service_plan_id               = azurerm_service_plan.main.id
  app_settings                  = var.app_settings
  public_network_access_enabled = var.public_network_access_enabled
  https_only                    = true
  virtual_network_subnet_id     = var.subnet_id
  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }
  logs {
    detailed_error_messages = var.logs.detailed_error_messages
    failed_request_tracing  = var.logs.failed_request_tracing
    http_logs {
      file_system {
        retention_in_days = var.logs.http_logs.file_system.retention_in_days
        retention_in_mb   = var.logs.http_logs.file_system.retention_in_mb
      }
    }
  }
  site_config {
    always_on                = var.always_on
    ftps_state               = var.ftps_state
    health_check_path        = var.health_check_path
    http2_enabled            = true
    minimum_tls_version      = "1.2"
    remote_debugging_enabled = false
    vnet_route_all_enabled   = true
    worker_count             = var.worker_count
    application_stack {
      dotnet_core_version          = try(var.application_stack.dotnet_core_version, null)
      dotnet_version               = try(var.application_stack.dotnet_version, null)
      java_embedded_server_enabled = try(var.application_stack.java_embedded_server_enabled, null)
      java_version                 = try(var.application_stack.java_version, null)
      node_version                 = try(var.application_stack.node_version, null)
      php_version                  = try(var.application_stack.php_version, null)
      python                       = false
    }
  }
}

resource "azurerm_private_endpoint" "web_app_ep" {
  for_each = { for key, value in var.private_endpoints :
    key => value
  if var.app_type == "web" }

  name                = "${local.resource_name_prefix}-${each.key}-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = azurerm_windows_web_app.main[0].id
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

# resource "azurerm_monitor_diagnostic_setting" "main" {
#   name                       = "${local.resource_name_prefix}${var.web_app_name}-diagnostics"
#   target_resource_id         = azurerm_windows_web_app.main[0].id
#   log_analytics_workspace_id = var.log_analytics_workspace_id
# }
