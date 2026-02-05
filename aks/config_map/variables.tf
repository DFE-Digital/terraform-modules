variable "namespace" {
  type        = string
  description = "Current namespace"
}

variable "environment" {
  type        = string
  description = "Current application environment"
}

variable "service_short" {
  type        = string
  description = "Short name of the service"
}

variable "config_short" {
  type        = string
  description = "Short name of the configuration"
}

variable "config_variables" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "Additional configuration variables"
}

variable "config_variables_path" {
  type        = string
  default     = null
  description = "Path to load additional configuration variables from"
}

variable "config_file_path" {
  type        = string
  default     = null
  description = "Path to load additional configuration data from"
}
