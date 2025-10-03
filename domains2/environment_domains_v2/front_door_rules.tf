# Rule set for redirects
resource "azurerm_cdn_frontdoor_rule_set" "redirects" {
  count = length(var.redirect_rules) > 0 ? 1 : 0

  name                     = "${substr(replace(var.environment, ".", "-"), 0, 20)}-redirects"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
}

# Individual redirect rules
resource "azurerm_cdn_frontdoor_rule" "redirects" {
  for_each = var.redirect_rules

  name                      = substr(replace(each.key, "_", "-"), 0, 260)
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.redirects[0].id
  order                     = index(keys(var.redirect_rules), each.key) + 1
  behavior_on_match         = "Continue"

  conditions {
    host_name_condition {
      operator     = "Equal"
      match_values = [each.value.from_domain]
    }

    url_path_condition {
      operator     = "BeginsWith"
      match_values = [each.value.from_path]
    }
  }

  actions {
    url_redirect_action {
      redirect_type        = each.value.redirect_type
      redirect_protocol    = "Https"
      destination_hostname = each.value.to_domain
      destination_path     = each.value.to_path
      query_string         = each.value.preserve_path ? "Preserve" : "StripAll"
      destination_fragment = ""
    }
  }
}