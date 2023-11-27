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

variable "service_name" {
  type        = string
  description = "Name of the service"
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

variable "server_docker_image" {
  type        = string
  default     = "postgres:14-alpine"
  description = "Database image to use with kubernetes deployment, eg. postgis/postgis:14-3.4"
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

variable "alert_window_size" {
  type        = string
  default     = "PT5M"
  description = "The period of time that is used to monitor alert activity e.g PT1M, PT5M, PT15M, PT30M, PT1H, PT6H or PT12H"
}

variable "azure_maintenance_window" {
  type = object({
    day_of_week  = optional(number)
    start_hour   = optional(number)
    start_minute = optional(number)
  })
  default = null
}

variable "azure_enable_backup_storage" {
  type    = bool
  default = true
}
