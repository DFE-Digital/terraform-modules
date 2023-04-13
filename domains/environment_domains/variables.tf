variable "zone" {}
variable "front_door_name" {}
variable "resource_group_name" {}
variable "domains" {}
variable "environment" {}
variable "host_name" {}
variable "null_host_header" {
  default     = false
  description = "The origin_host_header for the azurerm_cdn_frontdoor_origin resource will be var.host_name (if false) or null (if true). If null then the host name from the incoming request will be used."
}

variable "rule_set_ids" {
  type    = list(any)
  default = null
}

variable "multiple_hosted_zones" {
  type    = bool
  default = false
}
variable "cached_paths" {
  type        = list(string)
  default     = []
  description = "List of path patterns such as /packs/* that front door will cache"
}

locals {
  # If true, removes .gov.uk and replaces remaining period with a hyphen e.g. 'domain.education.gov.uk' becomes domain-edu.
  # We shorten the zone name as the fd endpoint name can only be a maximum of 46 chars
  # This works around an issue where two front doors in the same resource group can't have an endpoint with the same name.
  # If false, removes anything after the first full stop/period e.g. 'domain.education.gov.uk' becomes just 'domain'.
  short_zone_name    = substr(replace(var.zone, "/^[^.]+\\./", ""), 0, 3)
  endpoint_zone_name = var.multiple_hosted_zones ? replace(var.zone, "/\\..+$/", "-${local.short_zone_name}") : replace(var.zone, "/\\..+$/", "")
  cached_domain_list = length(var.cached_paths) > 0 ? var.domains : []
}
