resource "azurerm_cdn_frontdoor_security_policy" "rate_limit" {
  count = var.single_policy ? 1 : 0

  name                     = "AllRateLimitSecurityPolicy"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.rate_limit[0].id

      association {
        dynamic "domain" {
          for_each = toset(var.hosted_zone)
          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.main[domain.key].id
          }
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
