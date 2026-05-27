variable "use_azure" {
  type        = bool
  description = "Whether to deploy using Azure Managed Redis service or Kubernetes. true = Azure Service, false = Kubernetes"
}

variable "name" {
  type        = string
  description = "Name of the instance that gets added as a suffix to the standard resource name."
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
  description = "Configuration map for the Kubernetes cluster"
}

variable "server_version" {
  type        = string
  nullable    = false
  default     = "6"
  description = "Version of Redis server to be used in the Kubernetes container only. The version of Azure Managed Redis when deployed in Azure is managed by Redis"
}

variable "azure_public_network_access_enabled" {
  description = "The public network access setting for the Managed Redis instance."
  type        = string
  nullable    = true
  default     = "Disabled"
}

variable "azure_memory_threshold" {
  type    = number
  default = 80
}

variable "azure_maxmemory_policy" {
  description = "Specifies how Redis decides which data to remove when it runs out of memory"
  type        = string
  default     = "AllKeysLRU"
  nullable    = false
  validation {
    condition = contains(["AllKeysLFU", "AllKeysLRU", "AllKeysRandom", "VolatileLRU", "VolatileLFU", "VolatileTTL",
    "VolatileRandom", "NoEviction"], var.azure_maxmemory_policy)
    error_message = "The azure_maxmemory_policy must be one of AllKeysLFU, AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileLFU, VolatileTTL"
  }
}

variable "db_clustering_policy" {
  description = "The default database clustering policy specified at create time"
  type        = string
  default     = "NoCluster"
  validation {
    condition     = contains(["EnterpriseCluster", "OSSCluster", "NoCluster"], var.db_clustering_policy)
    error_message = "The db_clustering_policy must be one of EnterpriseCluster, OSSCluster, NoCluster"
  }
}

variable "azure_enable_monitoring" {
  description = "Enable monitoring for the database server if using Azure Postgresql"
  type        = bool
  nullable    = false
  default     = true
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

variable "server_docker_repo" {
  type     = string
  nullable = false
  default  = "ghcr.io/dfe-digital/teacher-services-cloud"
}

variable "azure_managed_redis_sku" {
  description = "The features and specification of the Managed Redis instance to deploy."
  type        = string
  default     = "Balanced_B1"
  nullable    = false
  validation {
    condition = contains(["Balanced_B0", "Balanced_B1", "Balanced_B10", "Balanced_B100", "Balanced_B1000", "Balanced_B150",
      "Balanced_B20", "Balanced_B250", "Balanced_B3", "Balanced_B350", "Balanced_B5", "Balanced_B50", "Balanced_B500", "Balanced_B700",
      "ComputeOptimized_X10", "ComputeOptimized_X100", "ComputeOptimized_X150", "ComputeOptimized_X20", "ComputeOptimized_X250",
      "ComputeOptimized_X3", "ComputeOptimized_X350", "ComputeOptimized_X5", "ComputeOptimized_X50", "ComputeOptimized_X500",
      "ComputeOptimized_X700", "FlashOptimized_A1000", "FlashOptimized_A1500", "FlashOptimized_A2000", "FlashOptimized_A250",
      "FlashOptimized_A4500", "FlashOptimized_A500", "FlashOptimized_A700", "MemoryOptimized_M10", "MemoryOptimized_M100",
      "MemoryOptimized_M1000", "MemoryOptimized_M150", "MemoryOptimized_M1500", "MemoryOptimized_M20", "MemoryOptimized_M2000",
      "MemoryOptimized_M250", "MemoryOptimized_M350", "MemoryOptimized_M50", "MemoryOptimized_M500", "MemoryOptimized_M700"],
    var.azure_managed_redis_sku)
    error_message = "The SKU must be one the values defined at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis#sku_name-1"
  }
}
