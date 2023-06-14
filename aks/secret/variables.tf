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

variable "name" {
  type        = string
  description = "Name of the secret key"
}

variable "is_yaml" {
  type        = bool
  default     = false
  description = "Whether to parse as YAML"
}
