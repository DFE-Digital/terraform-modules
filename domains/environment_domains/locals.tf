locals {
  # If true, removes .gov.uk and replaces remaining period with a hyphen e.g. 'domain.education.gov.uk' becomes domain-edu.
  # We shorten the zone name as the fd endpoint name can only be a maximum of 46 chars
  # This works around an issue where two front doors in the same resource group can't have an endpoint with the same name.
  # If false, removes anything after the first full stop/period e.g. 'domain.education.gov.uk' becomes just 'domain'.
  short_zone_name    = substr(replace(var.zone, "/^[^.]+\\./", ""), 0, 3)
  endpoint_zone_name = var.multiple_hosted_zones ? replace(var.zone, "/\\..+$/", "-${local.short_zone_name}") : replace(var.zone, "/\\..+$/", "")

  cached_domain_list = length(var.cached_paths) > 0 ? var.domains : []

  max_frontdoor_endpoint_name_length = 46

  name_suffix = replace(var.zone, ".", "-")
}
