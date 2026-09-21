output "data_factory_id" {
  value = azurerm_data_factory.main.id
}

output "data_factory_name" {
  value = azurerm_data_factory.main.name
}

output "data_factory_identity_tenant_id" {
  value = azurerm_data_factory.main.identity.0.tenant_id
}

output "data_factory_identity_principal_id" {
  value = azurerm_data_factory.main.identity.0.principal_id
}

output "data_factory_alerts" {
  value = local.azure_enable_monitoring ? {
    PipelineFailedRuns   = azurerm_monitor_metric_alert.failed_pipelines[0].id
    ResourceCount        = azurerm_monitor_metric_alert.total_entities_count[0].id
    FactorySizeInGbUnits = azurerm_monitor_metric_alert.total_factory_size[0].id
  } : null
}
