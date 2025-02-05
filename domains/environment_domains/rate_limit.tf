resource "azurerm_cdn_frontdoor_firewall_policy" "rate_limit" {
  count = var.rate_limit != null ? 1 : 0

  name                              = "${var.environment}RateLimitFirewallPolicy"
  resource_group_name               = var.resource_group_name
  sku_name                          = data.azurerm_cdn_frontdoor_profile.main.sku_name
  mode                              = "Prevention"
  custom_block_response_status_code = 429

  custom_rule {
    name                           = "${var.environment}RateLimit${var.rate_limit}"
    rate_limit_duration_in_minutes = 5
    rate_limit_threshold           = var.rate_limit
    type                           = "RateLimitRule"
    action                         = "Block"

    # This match condition must match all requests (Host header size is not zero)
    match_condition {
      match_variable = "RequestHeader"
      selector       = "Host"
      operator       = "GreaterThanOrEqual"
      match_values   = ["0"]
    }
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_cdn_frontdoor_security_policy" "rate_limit" {
  count = var.rate_limit != null ? 1 : 0

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
