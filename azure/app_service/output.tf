output "id" {
  description = "The ID of the App Service"

  value = azurerm_windows_web_app.main[0].id
}

output "name" {
  description = "The name of the App Service"

  value = azurerm_windows_web_app.main[0].name
}

# output "principal_id" {
#   description = "The principal ID of the App Service"

#   value = azurerm_windows_web_app.main[0].principal_id
# }

output "default_hostname" {
  description = "The default hostname of the App Service"

  value = azurerm_windows_web_app.main[0].default_hostname
}

output "outbound_ip_addresses" {
  description = "The outbound IP addresses of the App Service"

  value = azurerm_windows_web_app.main[0].outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the App Service"

  value = azurerm_windows_web_app.main[0].possible_outbound_ip_addresses
}
