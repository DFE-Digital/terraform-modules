locals {
  # If true, removes .gov.uk and replaces remaining period with a hyphen e.g. 'domain.education.gov.uk' becomes domain-edu.
  # We shorten the zone name as the fd endpoint name can only be a maximum of 46 chars
  # This works around an issue where two front doors in the same resource group can't have an endpoint with the same name.
  # If false, removes anything after the first full stop/period e.g. 'domain.education.gov.uk' becomes just 'domain'.
  short_zone_name    = substr(replace(var.zone, "/^[^.]+\\./", ""), 0, 3)
  endpoint_zone_name = var.multiple_hosted_zones ? replace(var.zone, "/\\..+$/", "-${local.short_zone_name}") : replace(var.zone, "/\\..+$/", "")

  # firewall policy names must be unique within the resource group, and consist of letters and numbers only
  short_policy_name_prefix = substr(replace(local.endpoint_zone_name, "-", ""), 0, 10)
  short_policy_name        = "${local.short_policy_name_prefix}${local.short_zone_name}"

  cached_domain_list = length(var.cached_paths) > 0 ? var.domains : []

  max_frontdoor_endpoint_name_length = 46

  # Metadata tagging for Azure DNS records based on domain names.
  # Classification is driven by the configured domains list.
  # Any domain not explicitly classified as Prod or Dev defaults to Test.
  prod_domains = [
    "apex",
    "www",
    "preprod",
    "preproduction",
    "sandbox",
    "sandbox.api",
    "tps-sandbox",
    "tps",
    "t",
    "api"
  ]

  dev_domains = [
    "dev",
    "development"
  ]

  environment_tags = {
    for domain in var.domains :
    domain => (
      contains(local.prod_domains, lower(domain))
      ? "Prod"
      : contains(local.dev_domains, lower(domain))
      ? "Dev"
      : "Test"
    )
  }
}
