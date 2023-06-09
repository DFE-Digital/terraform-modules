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

variable "application_key_vault_secret_name" {
  type        = string
  description = "Secret name of the key vault to load application secrets from"
  default     = "APPLICATION"
}

variable "infrastructure_key_vault_secret_name" {
  type        = string
  description = "Secret name of the key vault to load infrastructure secrets from"
  default     = "INFRASTRUCTURE"
}
