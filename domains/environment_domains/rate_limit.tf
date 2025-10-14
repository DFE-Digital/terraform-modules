resource "azurerm_cdn_frontdoor_firewall_policy" "rate_limit" {
  count = length(var.rate_limit) > 0 || var.rate_limit_max != null || var.allow_aks || var.block_ip ? 1 : 0

  name                              = "${local.short_policy_name}${var.environment}RateLimitFirewallPolicy"
  resource_group_name               = var.resource_group_name
  sku_name                          = data.azurerm_cdn_frontdoor_profile.main.sku_name
  mode                              = "Prevention"
  custom_block_response_status_code = 429

  dynamic "custom_rule" {
    for_each = var.rate_limit
    content {
      name                           = custom_rule.value["agent"]
      priority                       = custom_rule.value["priority"]
      enabled                        = try(custom_rule.value["enabled"], "true")
      rate_limit_duration_in_minutes = custom_rule.value["duration"]
      rate_limit_threshold           = custom_rule.value["limit"]
      type                           = try(custom_rule.value["type"], "RateLimitRule")
      action                         = try(custom_rule.value["action"], "Block")

      # To match all requests use Host header size is not zero
      match_condition {
        match_variable = try(custom_rule.value["match_variable"], "RequestHeader")
        selector       = try(custom_rule.value["selector"], "")
        operator       = custom_rule.value["operator"]
        match_values   = ["${custom_rule.value["match_values"]}"]
      }
    }
  }

  dynamic "custom_rule" {
    for_each = var.rate_limit_max != null ? ["this"] : []
    content {
      name                           = "all"
      priority                       = 100
      rate_limit_duration_in_minutes = 5
      rate_limit_threshold           = var.rate_limit_max
      enabled                        = "true"
      type                           = "RateLimitRule"
      action                         = "Block"

      match_condition {
        match_variable = "RequestHeader"
        selector       = "Host"
        operator       = "GreaterThanOrEqual"
        match_values   = ["0"]
      }
    }
  }

  dynamic "custom_rule" {
    for_each = var.allow_aks ? ["this"] : []
    content {
      name     = "AKS"
      priority = 10
      enabled  = "true"
      type     = "MatchRule"
      action   = "Allow"

      match_condition {
        match_variable = "RemoteAddr"
        operator       = "IPMatch"
        match_values   = ["20.117.102.231", "20.90.254.33", "172.167.85.211"]
      }
    }
  }

  dynamic "custom_rule" {
    for_each = var.block_ip ? ["this"] : []
    content {
      name     = "blockIP"
      priority = 5
      enabled  = "false"
      type     = "MatchRule"
      action   = "Block"

      match_condition {
        match_variable = "RemoteAddr"
        operator       = "IPMatch"
        match_values   = ["10.1.1.1"]
      }
    }
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_cdn_frontdoor_security_policy" "rate_limit" {
  count = length(var.rate_limit) > 0 || var.rate_limit_max != null || var.allow_aks || var.block_ip ? 1 : 0

  name                     = "${var.environment}RateLimitSecurityPolicy"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.rate_limit[0].id

      association {
        dynamic "domain" {
          for_each = toset(var.domains)
          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.main[domain.key].id
          }
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
