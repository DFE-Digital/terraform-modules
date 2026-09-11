# Service variables
variable "subscription_short" {
  type        = string
  description = "The short name of the subscription e.g. s189"
}

variable "env_short" {
  type        = string
  description = "The short name of the environment e.g. d01, t01, p01"
}

variable "service_short" {
  type        = string
  description = "The short name of the service e.g. gias"
}

variable "service_name" {
  type        = string
  description = "The full name of the service e.g. get-information-about-schools"
}

variable "environment" {
  type        = string
  description = "The full name of the application service environment e.g. development, test, production"
}

variable "config_short" {
  type        = string
  description = "The short name of the environment configuration e.g. dv, ts, pd"
}

# Service Plan Variables
variable "sp_name" {
  type        = string
  description = "The name of the application service plan."
  default     = ""

  nullable = false
}

variable "sp_os_type" {
  type        = string
  description = "The operating system type of the application service plan."
  default     = "Windows"

  nullable = false
}

variable "sp_sku_name" {
  type        = string
  description = "The SKU name of the application service plan."
  default     = "S1"

  nullable = false
}

variable "maximum_elastic_worker_count" {
  type        = number
  description = "The maximum number of elastic workers for the application service plan."
  default     = null
}

variable "worker_count" {
  type        = number
  description = "The number of workers (instances) for the application service plan."
  default     = 1
}

variable "premium_plan_auto_scale_enabled" {
  type        = bool
  description = "Whether to enable auto-scaling for the premium application service plan."
  default     = false
}

# Common Variables
variable "app_type" {
  type        = string
  description = "The type of application to be deployed (e.g., web, function)."

  nullable = false
}

# Web App Variables
variable "web_app_name" {
  type        = string
  description = "The name of the Web App that gets added as a suffix to the standard resource name."
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "The id of the subnet which will be used by this Web App"
  default     = null
}

variable "app_settings" {
  type        = map(string)
  description = "A map of key-value pairs to configure the Web App settings."
  default     = {}
}

variable "health_check_path" {
  type        = string
  description = "The path to the health check endpoint for the Web App."
  default     = null
}

variable "always_on" {
  type        = bool
  description = "Whether to enable the Always On feature for the Web App."
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed for the Web App."
  default     = true
}

variable "ftps_state" {
  type        = string
  description = "The FTPS state for the Web App. Possible values are 'AllAllowed', 'FtpsOnly', or 'Disabled'."
  default     = "Disabled"
}

variable "application_stack" {
  type = object({
    dotnet_core_version = optional(string)
    dotnet_version      = optional(string)
    java_version        = optional(string)
    node_version        = optional(string)
    php_version         = optional(string)
  })
  description = "The application stack configuration for the Web App."
  default     = {}
}

variable "logs" {
  type = object({
    detailed_error_messages = optional(bool)
    failed_request_tracing  = optional(bool)
    http_logs = optional(object({
      file_system = optional(object({
        retention_in_days = optional(number)
        retention_in_mb   = optional(number)
      }))
    }))
  })
  description = "The logging configuration for the Web App."
  default     = {}
}

variable "private_endpoints" {
  type = map(object({
    subnet_id           = string
    private_dns_zone_id = string
  }))
  description = "A map defining one or more private endpoints for the Web App"
  default     = {}
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The id of the subnet which will be used by the private endpoint"
  default     = null
}

# Function App Variables
variable "function_app_name" {
  type        = string
  description = "The name of the Function App that gets added as a suffix to the standard resource name."
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account that gets added as a suffix to the standard resource name."
  default     = null
}

variable "storage_account_access_key" {
  type        = string
  description = "The access key for the storage account used by the Function App."
  default     = null
}

# Monitoring Variables
variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace to which diagnostic logs will be sent."
  default     = null
}
