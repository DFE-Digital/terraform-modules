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

variable "server_version" {
  type        = string
  nullable    = false
  default     = "6"
  description = "Version of Redis server"
}

variable "use_azure" {
  type        = bool
  description = "Whether to deploy using Azure Redis Cache service"
}

variable "azure_capacity" {
  type    = number
  default = 1
}

variable "azure_family" {
  type    = string
  default = "C"
}

variable "azure_sku_name" {
  type    = string
  default = "Standard"
}

variable "azure_minimum_tls_version" {
  type     = string
  nullable = false
  default  = "1.2"
}

variable "azure_public_network_access_enabled" {
  type     = bool
  nullable = false
  default  = false
}

variable "azure_memory_threshold" {
  type    = number
  default = 80
}

variable "azure_maxmemory_policy" {
  type     = string
  nullable = false
  default  = "allkeys-lru"
}

variable "azure_enable_monitoring" {
  type     = bool
  nullable = false
  default  = true
}

variable "azure_patch_schedule" {
  type = list(object({
    day_of_week        = string,
    start_hour_utc     = optional(number),
    maintenance_window = optional(string)
  }))
  nullable = false
  default  = []
}

variable "alert_window_size" {
  type     = string
  default  = "PT5M"
  nullable = false
  validation {
    condition     = contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H"], var.alert_window_size)
    error_message = "The alert_window_size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H"
  }
  description = "The period of time that is used to monitor alert activity e,g, PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly."
}
