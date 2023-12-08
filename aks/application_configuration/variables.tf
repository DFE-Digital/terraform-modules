variable "namespace" {
  type        = string
  description = "Current namespace"
}

variable "environment" {
  type        = string
  description = "Current application environment"
}

variable "azure_resource_prefix" {
  type        = string
  description = "Prefix of Azure resources for the service"
}

variable "service_short" {
  type        = string
  description = "Short name of the service"
}

variable "config_short" {
  type        = string
  description = "Short name of the configuration"
}

variable "is_rails_application" {
  type        = bool
  nullable    = false
  default     = false
  description = "If true, sets config variables for a Rails application"
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

variable "secret_key_vault_short" {
  type        = string
  default     = null
  description = "Short name of the key vault which stores application secrets"
}

variable "secret_yaml_key" {
  type        = string
  default     = null
  description = "If set, secrets will also be extracted from a YAML key"
}

variable "secret_variables" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "Additional secret variables"
}
