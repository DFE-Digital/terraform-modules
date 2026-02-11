output "front_door_profile_id" {
  description = "The ID of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "front_door_profile_name" {
  description = "The name of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.main.name
}

output "front_door_resource_group_name" {
  description = "The resource group name of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.main.resource_group_name
}

output "dns_zones" {
  description = "Map of DNS zones with their details"
  value = {
    for k, v in azurerm_dns_zone.main : k => {
      id                  = v.id
      name                = v.name
      resource_group_name = v.resource_group_name
      name_servers        = v.name_servers
    }
  }
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace (if monitoring is enabled)"
  value       = var.azure_enable_monitoring ? azurerm_log_analytics_workspace.main[0].id : null
}