locals {
  name = var.name != null ? var.name : "default"
  storage_account_name = var.storage_account_name_override != null ? var.storage_account_name_override : lower(
    "${var.azure_resource_prefix}${var.service_short}${local.name}${var.config_short}sa"
  )

  # Determine replication type based on environment
  effective_replication_type = var.use_production_replication ? var.production_replication_type : var.account_replication_type

  default_tags = {
    Service     = var.service_name
    Environment = var.environment
  }
  tags = merge(local.default_tags, var.tags)

  # Default management policy for deleting blobs after 7 days
  default_management_policy_rule = {
    name    = "DeleteAfter7Days"
    enabled = true
    filters = {
      blob_types = ["blockBlob"]
    }
    actions = {
      base_blob = {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }

  # Combine default policy with custom policies if default_management_policy is true
  management_policy_rules = var.default_management_policy ? concat([local.default_management_policy_rule], var.management_policy_rules) : var.management_policy_rules
}

data "azurerm_resource_group" "main" {
  count = var.use_azure ? 1 : 0
  name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
}

resource "azurerm_storage_account" "main" {
  count = var.use_azure && var.create_storage_account ? 1 : 0

  name                             = local.storage_account_name
  resource_group_name              = data.azurerm_resource_group.main[0].name
  location                         = var.location_override != null ? var.location_override : data.azurerm_resource_group.main[0].location
  account_kind                     = var.account_kind
  account_tier                     = var.account_tier
  account_replication_type         = local.effective_replication_type
  access_tier                      = var.access_tier
  min_tls_version                  = var.min_tls_version
  enable_https_traffic_only        = var.enable_https_traffic_only
  public_network_access_enabled    = var.public_network_access_enabled
  allow_nested_items_to_be_public  = var.allow_nested_items_to_be_public
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

  blob_properties {
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_delete_retention_days
    }

    last_access_time_enabled = var.last_access_time_enabled
  }

  network_rules {
    default_action             = var.network_rules.default_action
    bypass                     = var.network_rules.bypass
    ip_rules                   = var.network_rules.ip_rules
    virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_encryption_scope" "main" {
  count = var.use_azure && var.create_storage_account && var.create_encryption_scope ? 1 : 0

  name               = var.encryption_scope_name
  storage_account_id = azurerm_storage_account.main[0].id
  source             = "Microsoft.Storage"
}

resource "azurerm_storage_container" "containers" {
  for_each = var.use_azure && var.create_storage_account ? { for container in var.containers : container.name => container } : {}

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.main[0].name
  container_access_type = each.value.access_type
}

resource "azurerm_storage_management_policy" "main" {
  count = var.use_azure && var.create_storage_account && (var.create_management_policy || var.default_management_policy) && length(local.management_policy_rules) > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.main[0].id

  dynamic "rule" {
    for_each = { for i, rule in local.management_policy_rules : i => rule }

    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      filters {
        prefix_match = lookup(rule.value.filters, "prefix_match", null)
        blob_types   = rule.value.filters.blob_types
      }

      actions {
        dynamic "base_blob" {
          for_each = contains(keys(rule.value.actions), "base_blob") ? [rule.value.actions.base_blob] : []

          content {
            tier_to_cool_after_days_since_modification_greater_than       = lookup(base_blob.value, "tier_to_cool_after_days_since_modification_greater_than", null)
            tier_to_archive_after_days_since_modification_greater_than    = lookup(base_blob.value, "tier_to_archive_after_days_since_modification_greater_than", null)
            delete_after_days_since_modification_greater_than             = lookup(base_blob.value, "delete_after_days_since_modification_greater_than", null)
            tier_to_cool_after_days_since_last_access_time_greater_than   = lookup(base_blob.value, "tier_to_cool_after_days_since_last_access_time_greater_than", null)
            tier_to_archive_after_days_since_last_access_time_greater_than = lookup(base_blob.value, "tier_to_archive_after_days_since_last_access_time_greater_than", null)
            delete_after_days_since_last_access_time_greater_than         = lookup(base_blob.value, "delete_after_days_since_last_access_time_greater_than", null)
          }
        }

        dynamic "snapshot" {
          for_each = contains(keys(rule.value.actions), "snapshot") ? [rule.value.actions.snapshot] : []

          content {
            change_tier_to_archive_after_days_since_creation = lookup(snapshot.value, "change_tier_to_archive_after_days_since_creation", null)
            change_tier_to_cool_after_days_since_creation    = lookup(snapshot.value, "change_tier_to_cool_after_days_since_creation", null)
            delete_after_days_since_creation_greater_than    = lookup(snapshot.value, "delete_after_days_since_creation_greater_than", null)
          }
        }

        dynamic "version" {
          for_each = contains(keys(rule.value.actions), "version") ? [rule.value.actions.version] : []

          content {
            change_tier_to_archive_after_days_since_creation = lookup(version.value, "change_tier_to_archive_after_days_since_creation", null)
            change_tier_to_cool_after_days_since_creation    = lookup(version.value, "change_tier_to_cool_after_days_since_creation", null)
            delete_after_days_since_creation                 = lookup(version.value, "delete_after_days_since_creation", null)
          }
        }
      }
    }
  }
}
