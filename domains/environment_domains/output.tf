output "endpoint_host_name" {
  value = var.add_to_endpoint_host_name == null ? azurerm_cdn_frontdoor_endpoint.main[var.domains[0]].host_name : var.add_to_endpoint_host_name
}
output "endpoint_id" {
  value = var.add_to_endpoint_id == null ? azurerm_cdn_frontdoor_endpoint.main[var.domains[0]].id : var.add_to_endpoint_id
}
