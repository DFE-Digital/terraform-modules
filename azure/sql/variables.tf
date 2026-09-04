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

variable "subnet_id" {
  default = null
}

variable "dnszone_name" {
  default = null
}

variable "dnszone_id" {
  default = null
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

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is allowed for the SQL logical server"
}

variable "storage_account_type" {
  type        = string
  default     = "Geo"
  description = "Storage account type for the Azure SQL database. Options: LRS, GRS, ZRS, RAGRS, RAGZRS"
}

# Database variables
variable "create_database" {
  type        = bool
  default     = true
  description = "Create default database. If the app creates the database instead of this module, set to false. Default: true"

  nullable = false
}

variable "extra_databases" {
  type        = list(string)
  default     = []
  description = "Additional SQL logical server databases to create on the same SQL logical server"

  nullable = false
}

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

variable "enable_immutable_backups" {
  type    = bool
  default = false
  description = "Specifies if the backups are immutable"

  nullable = false
}

variable "lt_ret_pol_week_of_year" {
  type    = number
  default = 1
  description = "Specifies the week of the year to retain the backup for. The value is a number between 1 and 52."

  nullable = false
}

variable "lt_ret_pol_weekly_retention" {
  type    = string
  default = "PT0S"
  description = "Specifies the number of weeks to retain the backup for. PT0S Period Time zero seconds. The value is a duration in ISO 8601 format."

  nullable = false
}

variable "lt_ret_pol_monthly_retention" {
  type    = string
  default = "PT0S"
  description = "Specifies the number of months to retain the backup for. PT0S Period Time zero seconds. The value is a duration in ISO 8601 format."

  nullable = false
}

variable "lt_ret_pol_yearly_retention" {
  type    = string
  default = "PT0S"
  description = "Specifies the number of years to retain the backup for. PT0S Period Time zero seconds. The value is a duration in ISO 8601 format."

  nullable = false
}

variable "st_ret_pol_backup_interval_in_hours" {
  type    = number
  default = 12
  description = "Specifies the interval in hours between backups. The value is a number between 1 and 24."

  nullable = false
}

variable "st_ret_pol_retention_days" {
  type    = number
  default = 7
  description = "Specifies the number of days to retain the backup for. The value is a number between 1 and 35."

  nullable = false
}

variable "threat_pol_state" {
  type        = string
  default     = "Disabled"
  description = "Specifies the state of the threat detection policy. Possible values are: Enabled, Disabled"

  nullable = false
}

variable "threat_pol_disabled_alerts" {
  type        = list(string)
  default     = []
  description = "Specifies the list of alerts that are disabled. Possible values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Data_Exfiltration_Vulnerability, Brute_Force, Sql_Injection_Brute_Force"

  nullable = false
}

variable "threat_pol_email_account_admins" {
  type        = string
  default     = "Disabled"
  description = "Specifies whether to send email notifications to the account administrators when a threat detection alert is triggered. Possible values are: Enabled, Disabled"

  nullable = false
}

variable "threat_pol_email_addresses" {
  type        = list(string)
  default     = []
  description = "Specifies the list of email addresses to send notifications to when a threat detection alert is triggered."

  nullable = false
}

variable "threat_pol_retention_days" {
  type        = number
  default     = 0
  description = "Specifies the number of days to retain threat detection logs. The value is a number between 0 and 365."

  nullable = false
}

variable "threat_pol_storage_account_access_key" {
  type        = string
  default     = ""
  description = "Specifies the access key of the storage account to store threat detection logs."

  nullable = false
}

variable "threat_pol_storage_endpoint" {
  type        = string
  default     = ""
  description = "Specifies the endpoint of the storage account to store threat detection logs."

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
