variable "zone" {
  description = "Azure DNS zone name (FQDN)"
}
variable "front_door_name" {
  description = "Azure front door name"
}
variable "resource_group_name" {
  description = "Name of the resource group where DNS zone and front door are deployed"
}
variable "domains" {
  description = "List of subdomains of the DNS zone. If the zone is staging.abc.education.gov.uk, then the domain is 'staging'. Use 'apex' for the apex domain"
}
variable "environment" {
  description = "Name of the application deployed environment"
}
variable "host_name" {
  description = "Full hostname of the origin (backend server)"
}
variable "null_host_header" {
  default     = false
  description = "The origin_host_header for the azurerm_cdn_frontdoor_origin resource will be var.host_name (if false) or null (if true). If null then the host name from the incoming request will be used."
}
variable "rule_set_ids" {
  type    = list(any)
  default = null
  description = "List of existing rule set ids to use on the front door routes"
}
variable "multiple_hosted_zones" {
  type    = bool
  default = false
  description = "Set to true when using multiple zones with the same name beginning e.g. abc.education.gov.uk and abc.service.gov.uk"
}
variable "cached_paths" {
  type        = list(string)
  default     = []
  description = "List of path patterns such as /packs/* that front door will cache"
}
variable "exclude_cnames" {
  default     = []
  description = "Don't create the CNAME for this record from var.domains. We set this when we want to configure front door for a services domain that we are migrating so we do not need to wait for the certificate to validate and front door to propagate the configuration."
}
