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

variable "config_short" {
  type        = string
  description = "The short name of the environment configuration e.g. dv, ts, pd"
}

# variable "web_app_name" {
#   type        = string
#   description = "The application name used to generate the default App Service Plan name."
# }

variable "sp_name" {
  type        = string
  description = "Override the generated App Service Plan name."
  default     = ""
}

variable "sp_infix" {
  type        = string
  description = "An optional infix to include in the generated App Service Plan name."
  default     = ""
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
