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

locals {
  endpoint_zone_name = replace(var.zone, ".education.gov.uk", "")
}
