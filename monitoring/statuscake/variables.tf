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

variable "confirmation" {
  type        = number
  description = "Retry the check when an error is detected to avoid false positives and micro downtimes"
  default     = 2
}
