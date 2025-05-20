resource "azurerm_cdn_frontdoor_firewall_policy" "rate_limit" {
  count = length(var.rate_limit) > 0 ? 1 : 0

  name                              = "${var.environment}RateLimitFirewallPolicy"
  resource_group_name               = var.resource_group_name
  sku_name                          = data.azurerm_cdn_frontdoor_profile.main.sku_name
  mode                              = "Prevention"
  custom_block_response_status_code = 429

  dynamic "custom_rule" {
    for_each = var.rate_limit
    content {
      name                           = custom_rule.value["agent"]
      priority                       = custom_rule.value["priority"]
      rate_limit_duration_in_minutes = custom_rule.value["duration"]
      rate_limit_threshold           = custom_rule.value["limit"]
      type                           = "RateLimitRule"
      action                         = "Block"

      # To match all requests use Host header size is not zero
      match_condition {
        match_variable = "RequestHeader"
        selector       = custom_rule.value["selector"]
        operator       = custom_rule.value["operator"]
        match_values   = ["${custom_rule.value["match_values"]}"]
      }
    }
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_cdn_frontdoor_security_policy" "rate_limit" {
  count = length(var.rate_limit) > 0 ? 1 : 0

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
