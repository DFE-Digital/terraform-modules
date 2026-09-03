#Service variables
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

# Server variables
variable "server_name_suffix" {
  type        = string
  default     = null
  description = "The name of the Azure SQL, SQL logical server. If not provided, a name will be generated based on the service_short and config_short variables."
}

variable "azure_name_override" {
  type        = string
  default     = null
  description = "Replace the generated name with hardcoded name"
}

variable "server_version" {
  type        = string
  default     = "12.0"
  description = "Version of the Azure SQL logical server"
}

variable "admin_username" {
  type        = string
  default     = null
  description = "Username of the admin user"
}

variable "admin_password" {
  type        = string
  default     = null
  description = "Password of the admin user"

  sensitive = true
}

# Database variables
variable "azure_sql_sku" {
  type        = string
  default     = "GP_Gen5_2"
  description = "SKU of the Azure SQL database"
}

variable "zone_redundant" {
  type        = bool
  default     = false
  description = "Whether replicas of the database will be spread across multiple availability zones"
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
  type    = bool
  default = true

  nullable = false
}

variable "alert_window_size" {
  type        = string
  default     = "PT5M"
  description = "The period of time that is used to monitor alert activity e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly."

  validation {
    condition     = contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H"], var.alert_window_size)
    error_message = "The alert_window_size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H"
  }

  nullable = false
}

variable "azure_enable_backup_storage" {
  type    = bool
  default = true

  nullable = false
}

variable "create_database" {
  type        = bool
  default     = true
  description = "Create default database. If the app creates the database instead of this module, set to false. Default: true"

  nullable = false
}

variable "extra_databases" {
  type        = list(string)
  default     = []
  description = "Additional PostgreSQL databases to create on the same PostgreSQL server"

  nullable = false
}

variable "azure_backup_storage_private_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Use a private endpoint for backup storage account access"
}

variable "azure_backup_storage_public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is allowed for the storage account"
}
