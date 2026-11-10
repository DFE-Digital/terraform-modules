# Generic subnet for private endpoints. This is used for private endpoints that are not in the other subnets, e.g. Key Vault, App Service, etc.
resource "azurerm_subnet" "private_endpoints" {
  count = var.enable_generic_private_endpoints ? 1 : 0

  name                 = "pe-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.main.name
  address_prefixes     = var.generic_private_endpoints_subnet

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_private_dns_zone" "generic" {
  for_each = toset(var.private_dns_zones)

  name                = each.value
  resource_group_name = data.azurerm_resource_group.main.name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_private_dns_zone_virtual_network_link" "generic" {
  for_each = toset(var.private_dns_zones)

  name                  = each.value
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}

#################################################################################

# data "azurerm_key_vault" "app" {
#   name = 
#   resource_group_name = data.azurerm_resource_group.main.name
# }

# data "azurerm_key_vault" "inf" {
#   name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-inf-kv"
#   resource_group_name = data.azurerm_resource_group.main.name
# }

# locals {  
#   azure_private_endpoint_name = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-k${local.name_suffix}-pe"
#   default_vaults = {
#     app = { 
#         name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-app-kv"
#         key_vault = data.azurerm_key_vault.app 
#         }
#     inf = { 
#         name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-inf-kv"
#         key_vault = data.azurerm_key_vault.inf 
#         }
#   }
# }

# resource "azurerm_private_endpoint" "default_vault" {
#   for_each = var.create_default_vault_private_endpoints ? { local.default_vaults } : {}

#   name                = each.value.name
#   location            = data.azurerm_resource_group.main.name.location
#   resource_group_name = data.azurerm_resource_group.main.name.name
#   subnet_id           = data.azurerm_subnet.private_endpoints.id

#   private_dns_zone_group {
#     name                 = data.azurerm_private_dns_zone.generic["privatelink.vaultcore.azure.net"].name
#     private_dns_zone_ids = [data.azurerm_private_dns_zone.generic["privatelink.vaultcore.azure.net"].id]
#   }

#   private_service_connection {
#     name                           = local.azure_private_endpoint_name
#     private_connection_resource_id = each.value.key_vault.id
#     is_manual_connection           = false
#     subresource_names              = ["vault"]
#   }

#   lifecycle {
#     ignore_changes = [
#       tags
#     ]
#   }
# }
