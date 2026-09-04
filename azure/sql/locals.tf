locals {
  database_name              = "${local.azure_name}-${var.service_short}-${var.environment}"
  database_username          = var.admin_username != null ? var.admin_username : "u${random_string.username[0].result}"
  original_database_password = var.admin_password != null ? var.admin_password : random_password.password[0].result
  database_password          = replace(local.original_database_password, "/\\$+/", "$") # Remove sequences of multiple dollar signs.
  extra_database_names       = [for db in var.extra_databases : "${local.database_name}_${db}"]

  name_suffix          = var.server_name_suffix != null ? "-${var.server_name_suffix}" : ""
  azure_generated_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-sql${local.name_suffix}"
  azure_name           = var.azure_name_override == null ? local.azure_generated_name : var.azure_name_override

  host = azurerm_mssql_server.main.fully_qualified_domain_name
  port = 1433

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
