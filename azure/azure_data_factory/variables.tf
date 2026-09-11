variable "environment" {
  type        = string
  description = "Deployment environment used for resource naming and tagging."
}

variable "azure_resource_prefix" {
  type        = string
  description = "Azure prefix used to construct globally unique Data Factory names."
}

variable "service_name" {
  type        = string
  description = "Name of the service"
}

variable "service_short" {
  type        = string
  description = "Short service identifier used for resource naming and tagging."
}

variable "config_short" {
  type        = string
  description = "Short name of the configuration"
}

variable "git_enabled_environment" {
  type        = string
  default     = "development"
  description = "Environment name for which GitHub source control should be enabled. Other environments are expected to be managed by separate GitHub workflows."
}

variable "git_repository" {
  type = object({
    repository_name    = string
    branch_name        = string
    root_folder        = optional(string, "/adf")
    publishing_enabled = optional(bool, false)
    host_name          = optional(string)
  })

  default = null

  description = "GitHub repository connection for Data Factory source control. Only GitHub is supported."
}

variable "azure_enable_monitoring" {
  description = "Enable monitoring for Azure Data Factory."
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

variable "azure_failed_pipeline_threshold" {
  type    = number
  default = 80
}
