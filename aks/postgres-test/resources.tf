# Providers

terraform {
  required_version = "= 1.14.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.61.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Locals

locals {

  database_name = "primary"

  # Tests Nine, Thirteen, Fourteen, and Seventeen:

  extra_databases = [
    "audit"
  ]

  # # Tests Ten, Eleven, Twelve, Eighteen, and Nineteen:

  # extra_databases = [
  #   "audit",
  #   "reporting"
  # ]

  extra_database_names = [
    for db in local.extra_databases :
    "${local.database_name}_${db}"
  ]

  read_replica_count = 0

  read_replicas = {
    for n in range(local.read_replica_count) :
    "replica-${n + 1}" => "replica-${n + 1}"
  }

  server_name           = "steve-test-postgres"

  database_username = "steels"
  database_password = "FALSE9transition7-!"

  database_sku_name = "GP_Standard_D2s_v3"
}




# # ---------------------------------------------------------------------------------------------------------- #

# # Test One: Create main server with one primary database and no read replicas (set read_replica_count to 0)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Two: Create a read replica of the main server (set read_replica_count to 1)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Three: Create second read replica (set read_replica_count to 2)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Four: Create third read replica (set read_replica_count to 3)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }


# # # ---------------------------------------------------------------------------------------------------------- #

# # # Test Five: Destroy the first read replica using Terraform CLI




# # # ---------------------------------------------------------------------------------------------------------- #

# # # Test Six: Redeploy all replicas to check added back in as replica-1 (keep read_replica_count at 3)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Seven: Destroy all read replicas (set read_replica_count to 0)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Eight: Destroy the all resources using Terraform CLI / apply (commenting out relevant resources)




# # ---------------------------------------------------------------------------------------------------------- #

# # Test Nine: Create main server with one extra database and no read replicas (update extra_databases list)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Ten: Create second extra database on main server (update extra_databases list)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Eleven: Create a read replica with two extra databases (set read_replica_count to 1)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Twelve: Create three read replicas with two extra databases (set read_replica_count to 3)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Thirteen: Destroy the second extra database (update extra_databases list)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }



# # ---------------------------------------------------------------------------------------------------------- #

# # Test Fourteen: Destroy read replica three (set read_replica_count to 2)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Fifteen: Remove the last of the extra databases (comment out the extra_databases list)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Sixteen: Destroy primary server by CLI / apply (commenting out relevant resources)


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Seventeen: Create main server with one extra database and three read replicas (set read_replica_count to 3)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

# lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Eighteen: Create second extra database (update extra_databases list)

# resource "azurerm_postgresql_flexible_server" "main" {
#   name                          = local.server_name
#   location                      = "uksouth"
#   resource_group_name           = "s189d01-steels-test-rg"
#   version                       = 17
#   administrator_login           = local.database_username
#   administrator_password        = local.database_password
#   create_mode                   = "Default"
#   storage_mb                    = 32768
#   sku_name                      = local.database_sku_name
#   public_network_access_enabled = true

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "main" {
#   name      = local.database_name
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

# resource "azurerm_postgresql_flexible_server" "replica" {
#   for_each = local.read_replicas

#   name                          = "${local.server_name}-${each.value}"
#   location                      = azurerm_postgresql_flexible_server.main.location
#   resource_group_name           = azurerm_postgresql_flexible_server.main.resource_group_name
#   create_mode                   = "Replica"
#   source_server_id              = azurerm_postgresql_flexible_server.main.id
#   storage_mb                    = azurerm_postgresql_flexible_server.main.storage_mb
#   sku_name                      = azurerm_postgresql_flexible_server.main.sku_name

#   lifecycle {
#     ignore_changes = [
#       tags,
#       # Allow Azure to manage deployment zone. Ignore changes.
#       zone,
#       # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
#       create_mode
#     ]
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "extra" {
#   for_each = toset(local.extra_database_names)

#   name      = each.value
#   server_id = azurerm_postgresql_flexible_server.main.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }


# # ---------------------------------------------------------------------------------------------------------- #

# # Test Nineteen: Destroy primary server by CLI / apply (commenting out relevant resources)

