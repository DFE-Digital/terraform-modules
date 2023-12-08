variable "uptime_urls" {
  type        = list(string)
  nullable    = false
  description = "Set of URLs to perform uptime checks on"
  default     = []
}

variable "ssl_urls" {
  type        = list(string)
  nullable    = false
  description = "Set of URLs to perform SSL checks on"
  default     = []
}

variable "contact_groups" {
  type        = list(string)
  nullable    = false
  description = "Contact groups for the alerts"
  default     = []
}

variable "confirmation" {
  type        = number
  nullable    = false
  description = "Retry the check when an error is detected to avoid false positives and micro downtimes"
  default     = 2
}
