output "id" {
  description = "The ID of the App Service"
  value = local.app_service_id
}

output "name" {
  description = "The name of the App Service"
  value = local.app_service_name
}

# output "principal_id" {
#   description = "The principal ID of the App Service"
#   value = azurerm_windows_web_app.main[0].principal_id
# }

output "default_hostname" {
  description = "The default hostname of the App Service"
  value = local.default_hostname
}

output "outbound_ip_addresses" {  
  description = "The outbound IP addresses of the App Service"
  value = local.outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the App Service"
  value = local.possible_outbound_ip_addresses
}

output "workspace_id" {
  description = "The ID of the Log Analytics Workspace used for monitoring the App Service"
  value = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].id : null
}
