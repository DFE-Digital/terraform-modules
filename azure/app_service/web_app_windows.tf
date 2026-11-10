resource "azurerm_windows_web_app" "main" {
  count = var.app_type == "windows_web" || var.app_type == "web" ? 1 : 0

  name                = "${local.resource_name_prefix}${var.config_short}-${var.web_app_name}-wa"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  service_plan_id     = var.service_plan_id
  # app_settings                  = local.app_settings
  app_settings                  = local.effective_app_settings
  public_network_access_enabled = var.public_network_access_enabled
  https_only                    = true
  virtual_network_subnet_id     = var.subnet_id

  identity {
    identity_ids = var.identity_ids
    type         = "SystemAssigned, ${var.identity_ids != null ? "UserAssigned" : ""}"
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
      tomcat_version               = try(var.application_stack.tomcat_version, null)
      node_version                 = try(var.application_stack.node_version, null)
      php_version                  = try(var.application_stack.php_version, null)
      python                       = false
    }
  }

  # sticky_settings {
  #   app_setting_names = var.sticky_app_settings
  # }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_windows_web_app_slot" "main" {
  for_each =  var.app_type == "windows_web" || var.app_type == "web" ? var.slots : {}

  name           = each.key
  app_service_id = azurerm_windows_web_app.main[0].id
  # app_settings = merge(
  #   local.app_settings,
  #   each.value.app_settings
  # )

  app_settings = merge(
    local.effective_app_settings,
    each.value.app_settings,
    local.slot_environment_settings[each.key]
  )

  https_only = true

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
      tomcat_version               = try(var.application_stack.tomcat_version, null)
      node_version                 = try(var.application_stack.node_version, null)
      php_version                  = try(var.application_stack.php_version, null)
      python                       = false
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
