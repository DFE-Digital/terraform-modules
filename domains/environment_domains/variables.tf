variable "zone" {}
variable "front_door_name" {}
variable "resource_group_name" {}
variable "domains" {}
variable "environment" {}
variable "host_name" {}
variable "rule_set_ids" {
  type    = list(any)
  default = null
}

variable "multiple_hosted_zones" {
  type = bool
  default = false
}

locals {
  # If true, removes .gov.uk and replaces remaining period with a hypthen e.g. 'domain.education.gov.uk' becomes domain-education.
  # This works around an issue where two front doors in the same resource group can't have an endpoint with the same name.
  # If false, removes anything after the first full stop/period e.g. 'domain.education.gov.uk' becomes just 'domain'.
  endpoint_zone_name = var.multiple_hosted_zones ? replace(replace(var.zone, ".gov.uk", ""), ".", "-") : replace(var.zone, "/\\..+$/", "")
}
