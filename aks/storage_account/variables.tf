variable "name" {
  type        = string
  description = "Name of the storage account (without prefix and suffix)"
  default     = null
}

variable "environment" {
  type        = string
  description = "Current application environment"
}

variable "azure_resource_prefix" {
  type        = string
  description = "Prefix of Azure resources for the service"
}

variable "service_short" {
  type        = string
  description = "Short name of the service"
}

variable "config_short" {
  type        = string
  description = "Short name of the configuration"
}

variable "storage_account_name_override" {
  type        = string
  description = "Override the generated storage account name with a custom name"
  default     = null
}

variable "production_replication_type" {
  type        = string
  description = "Replication type for production environments. Non-production environments always use LRS for cost efficiency."
  default     = "GRS"
  validation {
    condition     = contains(["ZRS", "GRS"], var.production_replication_type)
    error_message = "The production_replication_type must be either 'ZRS' or 'GRS'"
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed for the storage account"
  default     = false
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  description = "Enable infrastructure encryption for the storage account"
  default     = true
}

variable "last_access_time_enabled" {
  type        = bool
  description = "Enable last access time tracking for blobs"
  default     = true
}

variable "blob_versioning_enabled" {
  type        = bool
  description = "Enable blob versioning"
  default     = false
}

variable "blob_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted blobs. Set to null to disable retention policy."
  default     = null
  validation {
    condition     = var.blob_delete_retention_days == null ? true : (var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365)
    error_message = "The blob_delete_retention_days must be between 1 and 365, or null to disable retention policy"
  }
}

variable "container_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted containers. Set to null to disable retention policy."
  default     = null
  validation {
    condition     = var.container_delete_retention_days == null ? true : (var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365)
    error_message = "The container_delete_retention_days must be between 1 and 365, or null to disable retention policy"
  }
}

variable "create_encryption_scope" {
  type        = bool
  description = "Whether to create a Microsoft-managed encryption scope"
  default     = true
}

variable "encryption_scope_name" {
  type        = string
  description = "Name of the encryption scope to create"
  default     = "microsoftmanaged"
}

variable "containers" {
  type        = list(object({ name = string }))
  description = "List of containers to create on the storage account (all containers will be private)"
  default     = []
}

variable "blob_delete_after_days" {
  type        = number
  description = "Number of days after which blobs will be deleted. Set to 0 to disable automatic deletion."
  default     = 7
  validation {
    condition     = var.blob_delete_after_days >= 0 && var.blob_delete_after_days <= 9999
    error_message = "The blob_delete_after_days must be between 0 and 9999. Set to 0 to disable."
  }
}

variable "pr_number" {
  type        = string
  description = "Pull request number for review environments. Used in storage account naming when environment is 'review'."
  default     = null
}
