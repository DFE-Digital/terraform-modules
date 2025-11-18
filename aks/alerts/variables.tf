variable "kubernetes_cluster_id" {
  type        = string
  default     = null
  description = "ID of the Kubernetes cluster"
}

variable "azure_enable_app_monitoring" {
  type        = bool
  nullable    = false
  default     = false
  description = "Whether to enable monitoring of container failures"
}

variable "environment" {
  type        = string
  description = "Current application environment"
}

variable "azure_resource_prefix" {
  type        = string
  default     = null
  description = "Prefix of Azure resources for the service"
}

variable "app_name" {
  type        = string
  description = "Name of the application"
  default     = null
}

variable "service_name" {
  type        = string
  description = "Name of the service"
}

variable "service_short" {
  type        = string
  default     = null
  description = "Short name of the service"
}

variable "azure_enable_db_monitoring" {
  type     = bool
  nullable = false
  default  = true
}

variable "config_short" {
  type        = string
  description = "Short name of the configuration"
}

variable "db_name" {
  type        = string
  description = "Name of postgres db"
  default     = null
}

variable "alert_window_size" {
  type     = string
  nullable = false
  default  = "PT5M"
  validation {
    condition     = contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H"], var.alert_window_size)
    error_message = "The alert_window_size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H"
  }
  description = "The period of time that is used to monitor alert activity e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly."
}

variable "azure_db_memory_threshold" {
  type    = number
  default = 80
}

variable "azure_db_cpu_threshold" {
  type    = number
  default = 80
}

variable "azure_db_storage_threshold" {
  type    = number
  default = 80
}

variable "azure_enable_redis_monitoring" {
  type     = bool
  nullable = false
  default  = false
}

variable "redis_cache_name" {
  type        = string
  description = "Name of redis cache"
  default     = null
}

variable "azure_redis_memory_threshold" {
  type    = number
  default = 80
}