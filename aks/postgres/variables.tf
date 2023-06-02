variable "name" {
  type        = string
  description = "Name of the instance"
  default     = null
}

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

variable "cluster_configuration_map" {
  type = object({
    resource_group_name = string,
    resource_prefix     = string,
    dns_zone_prefix     = optional(string),
    cpu_min             = number
  })
  description = "Configuration map for the cluster"
}

variable "server_version" {
  type        = string
  default     = "14"
  description = "Version of PostgreSQL server"
}

variable "admin_username" {
  type        = string
  description = "Username of the admin user"
  default     = null
}

variable "admin_password" {
  type        = string
  description = "Password of the admin user"
  sensitive   = true
  default     = null
}

variable "use_azure" {
  type        = bool
  description = "Whether to deploy using Azure Redis Cache service"
}

variable "azure_storage_mb" {
  type    = number
  default = 32768
}

variable "azure_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "azure_enable_high_availability" {
  type    = bool
  default = false
}

variable "azure_extensions" {
  type    = list(string)
  default = []
}

variable "azure_memory_threshold" {
  type    = number
  default = 75
}

variable "azure_cpu_threshold" {
  type    = number
  default = 60
}

variable "azure_storage_threshold" {
  type    = number
  default = 75
}

variable "azure_enable_monitoring" {
  type    = bool
  default = true
}

variable "azure_maintenance_window" {
  type = object({
    day_of_week  = optional(number)
    start_hour   = optional(number)
    start_minute = optional(number)
  })
  default = null
}

variable "azure_backup_storage_account" {
  type    = bool
  default = true
}
