variable "uptime_urls" {
  type        = list(string)
  description = "Set of URLs to perform uptime checks on"
  default     = []
}

variable "ssl_urls" {
  type        = list(string)
  description = "Set of URLs to perform SSL checks on"
  default     = []
}

variable "contact_groups" {
  type        = list(string)
  description = "Contact groups for the alerts"
  default     = []
}
