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

variable "key_vault_secret_name" {
  type        = string
  description = "Secret name of the key vault to load secrets from"
  default     = "APPLICATION"
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
