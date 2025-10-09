variable "name" {
  type        = string
  description = "Name of the instance"
  default     = null
}

variable "azure_name_override" {
  type        = string
  description = "Replace the generated name with hardcoded name"
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
  default     = null
  description = "Docker Hub image for the kubernetes deployment, eg. postgis/postgis:16-3.5. Default is postgres:<server_version>-alpine"
}

variable "server_version" {
  type        = string
  default     = "16"
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

variable "azure_storage_tier" {
  type        = string
  description = "Tier of storage used by the PostgreSQL Flexible Server. Possible values are P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80. Defaults to Premium if not specified. The storage tier available depends on the azure_storage_mb value, see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#storage_tier-defaults-based-on-storage_mb for details."
  default     = null
  validation {
    condition     = var.azure_storage_tier == null ? true : contains(["P4", "P6", "P10", "P15", "P20", "P30", "P40", "P50", "P60", "P70", "P80"], var.azure_storage_tier)
    error_message = "The azure_storage_tier must be one of: P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80"
  }
}

variable "azure_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "azure_enable_high_availability" {
  type     = bool
  nullable = false
  default  = false
}

variable "azure_extensions" {
  type     = list(string)
  nullable = false
  default  = []
}

variable "azure_memory_threshold" {
  type    = number
  default = 80
}

variable "azure_cpu_threshold" {
  type    = number
  default = 80
}

variable "azure_storage_threshold" {
  type    = number
  default = 80
}

variable "azure_enable_monitoring" {
  type     = bool
  nullable = false
  default  = true
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

variable "azure_maintenance_window" {
  type = object({
    day_of_week  = optional(number)
    start_hour   = optional(number)
    start_minute = optional(number)
  })
  default = null
}

variable "azure_enable_backup_storage" {
  type     = bool
  nullable = false
  default  = true
}

variable "create_database" {
  default     = true
  nullable    = false
  description = "Create default database. If the app creates the database instead of this module, set to false. Default: true"
}

variable "server_docker_repo" {
  type     = string
  nullable = false
  default  = "ghcr.io/dfe-digital/teacher-services-cloud"
}

variable "use_airbyte" {
  type        = bool
  default     = false
  description = "Whether to add configuration changes required by Airbyte"
}

variable "server_postgis_version" {
  type        = string
  default     = "null"
  description = "Version of Postgis server"
}

variable "server_database_type" {
  type        = string
  default     = null
  description = "postgres or postgis"
}

locals {

  server_docker_image = coalesce(
    var.server_postgis_version != null
      ? "${var.server_docker_repo}:postgis-${var.server_postgis_version}"
      : null,
    var.server_docker_image,
    "${var.server_docker_repo}:postgres-${var.server_version}-alpine"
  )

  server_database_type = var.server_postgis_version == null ? "postgres" : "postges"


  command             = var.use_airbyte ? ["postgres", "-c", "wal_level=logical", "-c", "max_wal_senders=2", "-c", "max_replication_slots=1", "-c", "max_slot_wal_keep_size=2048"] : null

  # Normalize extensions to lower case for comparison
  normalize_extensions = [
    for ext in var.azure_extensions : lower(ext)
  ]
  # Determine if PostGIS needs to be added to the extensions list
  needs_postgis = var.server_postgis_version != null && var.server_postgis_version != "" 

  # Final list of extensions, adding PostGIS if needed
  azure_extensions_final = (
   local.needs_postgis
      ? (
         contains(local.normalize_extensions, "postgis")
           ? var.azure_extensions                  # already present (maybe in different case), so leave original list
           : concat(var.azure_extensions, ["postgis"])
       )
      : var.azure_extensions
  )
}
