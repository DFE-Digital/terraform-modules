locals {
  data_factory_name             = lower(replace("${var.azure_resource_prefix}-${var.service_short}-${var.environment}-adf", "/[^a-z0-9-]/", ""))
  standard_storage_account_name = substr(lower(replace("${var.azure_resource_prefix}${var.service_short}${var.environment}adf", "/[^a-z0-9]/", "")), 0, 24)
  git_enabled                   = var.git_repository != null && var.environment == var.git_enabled_environment
  azure_enable_monitoring       = var.azure_enable_monitoring
  github_account_name           = "DFE-Digital"

  alert_frequency_map = {
    PT5M  = "PT1M"
    PT15M = "PT1M"
    PT30M = "PT1M"
    PT1H  = "PT1M"
    PT6H  = "PT5M"
    PT12H = "PT5M"
  }
  alert_frequency = local.alert_frequency_map[var.alert_window_size]
}

resource "azurerm_data_factory" "main" {
  name                = local.data_factory_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  identity {
    type = "SystemAssigned"
  }

  public_network_enabled          = true
  managed_virtual_network_enabled = true

  dynamic "github_configuration" {
    for_each = local.git_enabled ? [var.git_repository] : []

    content {
      account_name       = local.github_account_name # preset to "DFE-Digital" for now, as this is the only account we currently support
      repository_name    = github_configuration.value.repository_name
      branch_name        = github_configuration.value.branch_name
      root_folder        = github_configuration.value.root_folder
      publishing_enabled = github_configuration.value.publishing_enabled
      git_url            = try(github_configuration.value.host_name, null)
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Base Alerts as per:
# https://learn.microsoft.com/en-us/azure/data-factory/monitor-data-factory#data-factory-alert-rules

resource "azurerm_monitor_metric_alert" "failed_pipelines" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_data_factory.main.name}-failed-pipeline"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_data_factory.main.id]
  description         = "Action will be triggered when failed pipeline runs are greater than ${var.azure_failed_pipeline_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.DataFactory/datafactories"
    metric_name      = "FailedRuns"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_failed_pipeline_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
    webhook_properties = {
      target_channels = var.service_short
      environment     = var.environment
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_metric_alert" "total_entities_count" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_data_factory.main.name}-total-entities"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_data_factory.main.id]
  description         = "Action will be triggered when the total number of entities in the Data Factory exceeds 1700000"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.DataFactory/datafactories"
    metric_name      = "ResourceCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1700000
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
    webhook_properties = {
      target_channels = var.service_short
      environment     = var.environment
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_metric_alert" "total_factory_size" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_data_factory.main.name}-total-factory-size"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [azurerm_data_factory.main.id]
  description         = "Action will be triggered whenever the maximum Total factory size (GB unit) is greater than 6"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.DataFactory/datafactories"
    metric_name      = "FactorySizeInGbUnits"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 6
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
    webhook_properties = {
      target_channels = var.service_short
      environment     = var.environment
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
