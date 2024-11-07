# Security and vulnerability disclosure redirects
resource "azurerm_cdn_frontdoor_rule_set" "security_redirects" {
  name                     = "${var.environment}SecurityRedirects"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
}

# Redirect for security.txt files
resource "azurerm_cdn_frontdoor_rule" "security_txt" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.main, azurerm_cdn_frontdoor_origin.main]

  name                      = "securityTxtRedirect"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_redirects.id
  order                     = 0
  behavior_on_match         = "Continue"

  conditions {
    url_path_condition {
      operator     = "BeginsWith"
      match_values = ["/.well-known/security.txt", "/security.txt"]
      transforms   = ["Lowercase"]
    }
  }

  actions {
    url_redirect_action {
      redirect_type        = "PermanentRedirect"
      redirect_protocol    = "Https"
      destination_hostname = "vdp.security.education.gov.uk"
      destination_path     = "/security.txt"
    }
  }
}

# Redirect for thanks.txt files
resource "azurerm_cdn_frontdoor_rule" "thanks_txt" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.main, azurerm_cdn_frontdoor_origin.main]

  name                      = "thanksTxtRedirect"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_redirects.id
  order                     = 1
  behavior_on_match         = "Continue"

  conditions {
    url_path_condition {
      operator     = "BeginsWith"
      match_values = ["/.well-known/thanks.txt", "/thanks.txt"]
      transforms   = ["Lowercase"]
    }
  }

  actions {
    url_redirect_action {
      redirect_type        = "PermanentRedirect"
      redirect_protocol    = "Https"
      destination_hostname = "vdp.security.education.gov.uk"
      destination_path     = "/thanks.txt"
    }
  }
}
