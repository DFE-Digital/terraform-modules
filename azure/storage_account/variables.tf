variable "name" {
  type        = string
  default     = null
  description = "Name of the storage account (without prefix and suffix)"
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
  default     = null
  description = "Override the generated storage account name with a custom name"
}

variable "production_replication_type" {
  type        = string
  default     = "GRS"
  description = "Replication type for production environments. Non-production environments always use LRS for cost efficiency."
  validation {
    condition     = contains(["ZRS", "GRS"], var.production_replication_type)
    error_message = "The production_replication_type must be either 'ZRS' or 'GRS'"
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether public network access is allowed for the storage account"
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  default     = false
  description = "Whether cross-tenant replication is enabled for the storage account"
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable infrastructure encryption for the storage account"
}

variable "last_access_time_enabled" {
  type        = bool
  default     = true
  description = "Enable last access time tracking for blobs"
}

variable "blob_versioning_enabled" {
  type        = bool
  default     = false
  description = "Enable blob versioning"
}

variable "blob_delete_retention_days" {
  type        = number
  default     = null
  description = "Number of days to retain deleted blobs. Set to null to disable retention policy."
  validation {
    condition     = var.blob_delete_retention_days == null ? true : (var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365)
    error_message = "The blob_delete_retention_days must be between 1 and 365, or null to disable retention policy"
  }
}

variable "container_delete_retention_days" {
  type        = number
  default     = null
  description = "Number of days to retain deleted containers. Set to null to disable retention policy."
  validation {
    condition     = var.container_delete_retention_days == null ? true : (var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365)
    error_message = "The container_delete_retention_days must be between 1 and 365, or null to disable retention policy"
  }
}

variable "create_encryption_scope" {
  type        = bool
  default     = true
  description = "Whether to create a Microsoft-managed encryption scope"
}

variable "encryption_scope_name" {
  type        = string
  default     = "microsoftmanaged"
  description = "Name of the encryption scope to create"
}

variable "containers" {
  type        = list(object({ name = string }))
  default     = []
  description = "List of containers to create on the storage account (all containers will be private)"
}

variable "blob_delete_after_days" {
  type        = number
  default     = 7
  description = "Number of days after which blobs will be deleted. Set to 0 to disable automatic deletion."
  validation {
    condition     = var.blob_delete_after_days >= 0 && var.blob_delete_after_days <= 9999
    error_message = "The blob_delete_after_days must be between 0 and 9999. Set to 0 to disable."
  }
}

variable "use_private_storage" {
  type        = bool
  default     = false
  description = "Whether to deploy a private Storage Account"
}

variable "queues" {
  type        = list(object({ name = string }))
  default     = []
  description = "List of queues to create on the storage account. Requires use_private_storage = true for private network access."
}

variable "cors_rules" {
  type = list(object({
    allowed_headers    = optional(list(string), ["Content-Type", "Content-MD5", "Content-Disposition", "x-ms-blob-content-disposition", "x-ms-blob-type"]),
    allowed_methods    = optional(list(string), ["PUT"]),
    allowed_origins    = optional(list(string)),
    exposed_headers    = optional(list(string), ["Content-Type"]),
    max_age_in_seconds = optional(number, 3600)
  }))
  default     = []
  description = "A list of CORS rules to apply to the storage account"

  validation {
    condition = alltrue([
      for rule in var.cors_rules :
      !contains(rule.allowed_headers, "*") &&
      !contains(rule.exposed_headers, "*") &&
      !contains(rule.allowed_origins, "*")
    ])
    error_message = "Wildcard values are not allowed in allowed_headers or exposed_headers."
  }
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
