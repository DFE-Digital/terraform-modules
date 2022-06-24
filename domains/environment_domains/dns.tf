data "azurerm_dns_zone" "main" {
  name                = var.zone
  resource_group_name = var.resource_group_name
}

# TODO: Create validation TXT record
# TODO: Create domain ALIAS A record
