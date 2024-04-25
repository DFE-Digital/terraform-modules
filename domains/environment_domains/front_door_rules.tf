resource "azurerm_cdn_frontdoor_rule_set" "redirects" {
  count = length(var.redirect_rules) > 0 ? 1 : 0

  name                     = var.add_to_front_door == null ? "${var.environment}Redirects" : "${var.environment}${local.name_suffix}Redirects"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_rule" "rule" {
  count      = length(var.redirect_rules)
  depends_on = [azurerm_cdn_frontdoor_origin_group.main, azurerm_cdn_frontdoor_origin.main]

  name                      = "rule${count.index}"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.redirects[0].id
  order                     = count.index
  behavior_on_match         = "Continue"

  conditions {
    host_name_condition {
      operator     = "Equal"
      match_values = [for d in [var.redirect_rules[count.index]["from-domain"]] : startswith(d, "apex") ? "${var.zone}" : "${d}.${var.zone}"]
    }
  }

  actions {
    url_redirect_action {
      redirect_type        = "PermanentRedirect"
      redirect_protocol    = "Https"
      destination_hostname = var.redirect_rules[count.index]["to-domain"]
      destination_path     = try(var.redirect_rules[count.index]["to-path"], null)
      query_string         = try(var.redirect_rules[count.index]["to-query-string"], null)
    }
  }
}
