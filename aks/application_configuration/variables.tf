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

variable "key_vault_name" {
  type        = string
  default     = null
  description = "Overrides the default Key Vault name. The default is $${var.azure_resource_prefix}-$${var.service_short}-$${var.config_short}-kv"
}

variable "key_vault_secret_name" {
  type        = string
  default     = "APPLICATION"
  description = "Secret name of the key vault to load secrets from"
}

variable "is_rails_application" {
  type        = bool
  default     = false
  description = "If true, sets config variables for a Rails application"
}

variable "config_variables" {
  type        = map(string)
  default     = {}
  description = "Additional configuration variables"
}

variable "config_variables_path" {
  type        = string
  default     = null
  description = "Path to load additional configuration variables from"
}

variable "secret_variables" {
  type        = map(string)
  default     = {}
  description = "Additional secret variables"
}
