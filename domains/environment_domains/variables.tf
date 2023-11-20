variable "zone" {}
variable "front_door_name" {}
variable "resource_group_name" {}
variable "domains" {
  description = <<EOF
    List of subdomains of the zone e.g. "staging". For apex domain use "apex" or "apex<something>" if apex is already in use
  EOF
}
variable "environment" {}
variable "host_name" {
  default     = "not-in-use.education.gov.uk"
  description = "Origin host name ie domain to where front door sends the requests. It may not be used if all requests are redirected."
}

variable "null_host_header" {
  default     = false
  description = "The origin_host_header for the azurerm_cdn_frontdoor_origin resource will be var.host_name (if false) or null (if true). If null then the host name from the incoming request will be used."
}

variable "rule_set_ids" {
  type    = list(any)
  default = []
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

variable "exclude_cnames" {
  default     = []
  description = "Don't create the CNAME for this record from var.domains. We set this when we want to configure front door for a services domain that we are migrating so we do not need to wait for the certificate to validate and front door to propagate the configuration."
}

variable "redirect_rules" {
  default     = {}
  description = <<EOF
    List of ordered redirect rules with format:
    [
      {
        "from-domain": "One of the domains from var.domains to redirect from",
        "to-domain": "Redirect destination domain",
        "to-path": "Optional path appended to the destination URL. If not provided, the path will be the same as in the incoming request",
        "to-query-string": "Optional path appended to the destination URL. If not provided, defaults to empty string"
      },
      {
        ...
      }
    ]
  EOF
}
