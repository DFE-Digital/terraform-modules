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
  type    = string
  default = "1.2"
}

variable "azure_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "azure_memory_threshold" {
  type    = number
  default = 60
}

variable "azure_maxmemory_policy" {
  type    = string
  default = "allkeys-lru"
}

variable "azure_enable_monitoring" {
  type    = bool
  default = true
}

variable "azure_patch_schedule" {
  type = list(object({
    day_of_week        = string,
    start_hour_utc     = optional(number),
    maintenance_window = optional(string)
  }))
  default = []
}
