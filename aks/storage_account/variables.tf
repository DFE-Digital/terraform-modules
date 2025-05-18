variable "name" {
  type        = string
  description = "Name of the storage account (without prefix and suffix)"
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
  type        = map(any)
  description = "Cluster configuration values"
}

variable "use_azure" {
  type        = bool
  description = "Whether to use Azure Storage Account or not"
  default     = true
}

variable "create_storage_account" {
  type        = bool
  description = "Whether to create the storage account"
  default     = true
}

variable "storage_account_name_override" {
  type        = string
  description = "Override the generated storage account name with a custom name"
  default     = null
}

variable "location_override" {
  type        = string
  description = "Override the location of the storage account. If not specified, uses the resource group's location."
  default     = null
}

variable "account_kind" {
  type        = string
  description = "Kind of storage account"
  default     = "StorageV2"
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "The account_kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2"
  }
}

variable "account_tier" {
  type        = string
  description = "Tier of storage account"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account_tier must be one of: Standard, Premium"
  }
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the storage account"
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "The account_replication_type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS"
  }
}

variable "production_replication_type" {
  type        = string
  description = "Replication type to use for production environments"
  default     = "GRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.production_replication_type)
    error_message = "The production_replication_type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS"
  }
}

variable "use_production_replication" {
  type        = bool
  description = "Whether to use the production replication type. If true, overrides account_replication_type with production_replication_type."
  default     = false
}

variable "access_tier" {
  type        = string
  description = "Access tier for the storage account"
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "The access_tier must be one of: Hot, Cool"
  }
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version required"
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "The min_tls_version must be one of: TLS1_0, TLS1_1, TLS1_2"
  }
}

variable "enable_https_traffic_only" {
  type        = bool
  description = "Forces HTTPS if enabled"
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed for the storage account"
  default     = false
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "Allow or disallow nested items within this Account to opt into being public"
  default     = false
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  description = "Allow or disallow cross-tenant replication"
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

variable "blob_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted blobs"
  default     = 7
  validation {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365
    error_message = "The blob_delete_retention_days must be between 1 and 365"
  }
}

variable "container_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted containers"
  default     = 7
  validation {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365
    error_message = "The container_delete_retention_days must be between 1 and 365"
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
  type        = list(object({ name = string, access_type = string }))
  description = "List of containers to create on the storage account"
  default     = []
  validation {
    condition = alltrue([
      for c in var.containers : contains(["private", "blob", "container"], c.access_type)
    ])
    error_message = "The access_type must be one of: private, blob, container"
  }
}

variable "network_rules" {
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  description = "Network rules for the storage account"
  default = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "The default_action must be one of: Allow, Deny"
  }
  validation {
    condition = alltrue([
      for b in var.network_rules.bypass : contains(["AzureServices", "Logging", "Metrics", "None"], b)
    ])
    error_message = "The bypass must be one or more of: AzureServices, Logging, Metrics, None"
  }
}

variable "create_management_policy" {
  type        = bool
  description = "Whether to create a storage management policy"
  default     = false
}

variable "management_policy_rules" {
  type = list(object({
    name    = string
    enabled = bool
    filters = object({
      blob_types   = list(string)
      prefix_match = optional(list(string))
    })
    actions = object({
      base_blob = optional(object({
        tier_to_cool_after_days_since_modification_greater_than              = optional(number)
        tier_to_archive_after_days_since_modification_greater_than           = optional(number)
        delete_after_days_since_modification_greater_than                    = optional(number)
        tier_to_cool_after_days_since_last_access_time_greater_than          = optional(number)
        tier_to_archive_after_days_since_last_access_time_greater_than       = optional(number)
        delete_after_days_since_last_access_time_greater_than                = optional(number)
      }))
      snapshot = optional(object({
        change_tier_to_archive_after_days_since_creation = optional(number)
        change_tier_to_cool_after_days_since_creation    = optional(number)
        delete_after_days_since_creation_greater_than    = optional(number)
      }))
      version = optional(object({
        change_tier_to_archive_after_days_since_creation = optional(number)
        change_tier_to_cool_after_days_since_creation    = optional(number)
        delete_after_days_since_creation                 = optional(number)
      }))
    }),
  }))
  description = "Rules for the storage management policy"
  default = []
}

variable "default_management_policy" {
  type        = bool
  description = "Whether to create a default management policy that deletes blobs after 7 days"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
