resource "statuscake_uptime_check" "main" {
  for_each = toset(var.uptime_urls)

  name           = each.value
  contact_groups = var.contact_groups
  confirmation   = var.confirmation
  trigger_rate   = var.trigger_rate
  check_interval = 30
  regions        = ["london", "london", "london"]

  http_check {
    follow_redirects = true
    timeout          = 40
    request_method   = "HTTP"
    status_codes     = ["204", "205", "206", "303", "400", "401", "403", "404", "405", "406", "408", "410", "413", "444", "429", "494", "495", "496", "499", "500", "501", "502", "503", "504", "505", "506", "507", "508", "509", "510", "511", "521", "522", "523", "524", "520", "598", "599"]
    validate_ssl     = true
    dynamic "content_matchers" {
      for_each = var.content_matchers
      content {
        matcher = content_matchers.value.matcher
        content = content_matchers.value.content
      }
    }
  }

  monitored_resource {
    address = each.value
  }
}

resource "statuscake_heartbeat_check" "main" {
  for_each = toset(var.heartbeat_names)

  name           = each.value
  period         = var.heartbeat_period
  contact_groups = var.contact_groups
}

output "heartbeat_check_urls" {
  value = { for name in var.heartbeat_names : name => statuscake_heartbeat_check.main[name].check_url }
}

resource "statuscake_ssl_check" "main" {
  for_each = toset(var.ssl_urls)

  contact_groups = var.contact_groups
  check_interval = 3600

  alert_config {
    alert_at = [3, 7, 30] # 1 month, 1 week then 3 days before expiration

    on_reminder = true
    on_expiry   = true
    on_broken   = true
    on_mixed    = true
  }

  monitored_resource {
    address = each.value
  }
}
