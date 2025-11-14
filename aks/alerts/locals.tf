locals {
  # app variables
  name_suffix = var.app_name != null ? "-${var.app_name}" : ""
  app_name    = "${var.service_name}-${var.environment}${local.name_suffix}"

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