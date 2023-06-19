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

variable "key_vault_short" {
  type        = string
  description = "Short name of the key vault"
  default     = null
}
