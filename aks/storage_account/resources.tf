locals {
  name = var.name != null ? var.name : "default"
  storage_account_name = var.storage_account_name_override != null ? var.storage_account_name_override : lower(
    "${var.azure_resource_prefix}${var.service_short}${local.name}${var.config_short}sa"
  )
}

data "azurerm_resource_group" "main" {
  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

resource "azurerm_storage_account" "main" {
  access_tier                       = "Hot"
  account_kind                      = "StorageV2"
  account_replication_type          = var.environment != "production" ? "LRS" : var.production_replication_type
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  location                          = "UK South"
  min_tls_version                   = "TLS1_2"
  name                              = local.storage_account_name
  public_network_access_enabled     = var.public_network_access_enabled
  resource_group_name               = data.azurerm_resource_group.main.name

  blob_properties {
    dynamic "delete_retention_policy" {
      for_each = var.blob_delete_retention_days != null ? [1] : []
      content {
        days = var.blob_delete_retention_days
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.container_delete_retention_days != null ? [1] : []
      content {
        days = var.container_delete_retention_days
      }
    }

    last_access_time_enabled = var.last_access_time_enabled
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_encryption_scope" "main" {
  count = var.create_encryption_scope ? 1 : 0

  name               = var.encryption_scope_name
  storage_account_id = azurerm_storage_account.main.id
  source             = "Microsoft.Storage"
}

resource "azurerm_storage_container" "containers" {
  for_each = { for container in var.containers : container.name => container }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_management_policy" "main" {
  count = var.blob_delete_after_days > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "DeleteAfter${var.blob_delete_after_days}Days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.blob_delete_after_days
      }
    }
  }
}
