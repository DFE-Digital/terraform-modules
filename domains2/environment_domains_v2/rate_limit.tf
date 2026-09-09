# WAF policy for rate limiting
resource "azurerm_cdn_frontdoor_firewall_policy" "rate_limit" {
  count = length(var.rate_limit_rules) > 0 ? 1 : 0

  name                              = replace("${substr(var.environment, 0, 20)}RateLimit", "-", "")
  resource_group_name               = var.resource_group_name
  sku_name                          = data.azurerm_cdn_frontdoor_profile.main.sku_name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 429
  custom_block_response_body        = base64encode("Rate limit exceeded. Please try again later.")

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Rate limit rules
resource "azurerm_cdn_frontdoor_firewall_policy_rule" "rate_limit" {
  for_each = var.rate_limit_rules

  cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.rate_limit[0].id
  name                              = replace(substr(each.key, 0, 128), "-", "")
  enabled                           = true
  priority                          = index(keys(var.rate_limit_rules), each.key) + 100
  rate_limit_duration_in_minutes    = each.value.duration_in_minutes
  rate_limit_threshold              = each.value.threshold
  type                              = "RateLimitRule"
  action                            = each.value.action

  match_condition {
    match_variable     = "RequestUri"
    operator           = "Any"
    negation_condition = false
    match_values       = [""]
  }

  match_condition {
    match_variable     = "RequestHeader"
    selector           = "Host"
    operator           = "Equal"
    negation_condition = false
    match_values       = [each.value.domain]
  }
}