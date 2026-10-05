#
# Can I move this back to the environment_domains?
# count = 1 only as soon as we create a domain, but each env_domain has its own terraform
# so we can't do this

# resource "azurerm_cdn_frontdoor_security_policy" "rate_limit" {
#   for_each = var.single_policy ? var.hosted_zone : {}

#   # name always AllRateLimitSecurityPolicy
#   # only create when we create a domain. That would be two step. Add domain, then go back and add rate limit

#   name                     = "AllRateLimitSecurityPolicy"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main[0].id

#   # must have a firewall policy and domain association.
#   # But I can remove an association in the portal and have no associations, and it didn't delete the security policy
#   # so maybe you can have a null association?
#   security_policies {
#     firewall {
#       cdn_frontdoor_firewall_policy_id = ""
#       association {
#         domain {
#           cdn_frontdoor_domain_id = ""
#         }
#         patterns_to_match = ["/*"]
#       }
#       # but it must know about the policies to import them, so that would be data resources
#       # do we have to move all the rate limiting to infra?
#       ###cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.rate_limit[0].id

#       ### association {
#       ###  dynamic "domain" {

#       ###    for_each = toset(var.hosted_zone)
#       ###    content {
#       ###      cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.main[domain.key].id
#       ###    }
#       ###  }
#       ###  patterns_to_match = ["/*"]
#       ### }
#     }
#   }
# }

resource "azurerm_cdn_frontdoor_firewall_policy" "rate_limit" {
  for_each = var.single_policy ? var.hosted_zone : {}

  # name must be nnnnnnnnnn nnn AllRateLimitFirewallPolicy suffix?
  # applyforteserpdRateLimitFirewallPolicy
  # applyforteedupdRateLimitFirewallPolicy
  # must be able to drop one as per the education -> service redirect
  # Required to crate a security policy

  # Could we add 1 single empty policy to ALL domains?
  # would save on working out naming here and leave it to the environment domains
  # if terraformed it would be created elsewhere, like tsc repo. That will be required for infra/domains v2 anyway
  # called SharedFWpolicy
  # No you can't share firewall policies between front door policies

  name                              = join("", [substr(replace(each.value.zone_name, "-", ""), 0, 10),substr(replace(each.value.zone_name, "/^[^.]+\\./", ""), 0, 3),"AllRateLimitFirewallPolicy${local.firewall_policy_suffix}"])
  resource_group_name               = each.value.resource_group_name
  sku_name                          = azurerm_cdn_frontdoor_profile.main[0].sku_name
  mode                              = "Prevention"
  custom_block_response_status_code = 429

#   # not required but possibly we could create overall rules here?
#   custom_rule {
#       name                           = "agent"
#       priority                       = 1
#       enabled                        = false
#       rate_limit_duration_in_minutes = 0
#       rate_limit_threshold           = 0
#       type                           = "MatchRule"
#       action                         = "Block"

#       # To match all requests use Host header size is not zero
#       match_condition {
#         match_variable = "RequestHeader"
#         #selector       = "IPMatch"
#         operator       = "IPMatch"
#         match_values   = "something"
#       }
#     }

  lifecycle { ignore_changes = [tags] }
}
