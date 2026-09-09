variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
}

variable "front_door_profile_name" {
  description = "Name of the Front Door profile to use"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Front Door profile"
  type        = string
}

variable "endpoint_configuration" {
  description = "Endpoint sharing configuration"
  type = object({
    strategy                 = string # "per_zone", "per_environment", or "shared"
    max_domains_per_endpoint = optional(number, 10)
  })
  default = {
    strategy                 = "per_environment"
    max_domains_per_endpoint = 10
  }
}

variable "domains" {
  description = "List of domains to configure"
  type = list(object({
    name                = string # Subdomain name (e.g., "www", "api", "apex-production")
    zone                = string # DNS zone name (e.g., "example.com")
    zone_resource_group = string # Resource group containing the DNS zone
    environment         = string # Environment for this domain
    origin_hostname     = string # Backend hostname (e.g., "myapp.azurewebsites.net")
    origin_host_header  = optional(string) # Host header to send to origin
    patterns_to_match   = list(string) # URL patterns (e.g., ["/*"])
    enable_caching      = optional(bool, false)
    cache_duration      = optional(number, 3600) # Cache duration in seconds
    enable_compression  = optional(bool, true)
    https_redirect      = optional(bool, true)
    exclude_cname       = optional(bool, false) # Skip CNAME record creation
    waf_policy_id       = optional(string) # WAF policy to attach
    rule_set_ids        = optional(list(string), []) # Rule sets to attach
  }))
}

variable "redirect_rules" {
  description = "Redirect rules configuration"
  type = map(object({
    from_domain     = string
    from_path       = optional(string, "/*")
    to_domain       = string
    to_path         = optional(string)
    redirect_type   = optional(string, "PermanentRedirect") # PermanentRedirect or TemporaryRedirect
    preserve_path   = optional(bool, true)
  }))
  default = {}
}

variable "rate_limit_rules" {
  description = "Rate limiting configuration per domain"
  type = map(object({
    domain              = string
    duration_in_minutes = number
    threshold           = number
    action              = string # "Allow", "Block", or "Log"
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}