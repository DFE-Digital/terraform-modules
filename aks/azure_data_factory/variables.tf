variable "environment" {
  type        = string
  description = "Deployment environment used for resource naming and tagging."
}

variable "service_short" {
  type        = string
  description = "Short service identifier used for resource naming and tagging."
}

variable "azure_resource_prefix" {
  type        = string
  description = "Azure prefix used to construct globally unique Data Factory names."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the Data Factory will be deployed."
}

variable "location" {
  type        = string
  description = "Azure location for the Data Factory."
}

variable "key_vault_name" {
  type        = string
  default     = null
  description = "Name of the Azure Key Vault from which credential-backed connection values should be read."
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
    root_folder        = optional(string, "/")
    publishing_enabled = optional(bool, true)
    host_name          = optional(string)
  })

  default = null

  description = "GitHub repository connection for Data Factory source control. Only GitHub is supported."
}

variable "create_standard_storage_account" {
  type        = bool
  default     = true
  description = "Whether to create a standard storage account for the Data Factory to use by default."
}

variable "sql_server_connections" {
  description = "SQL Server connections represented by Key Vault secret names."
  type = list(object({
    name                        = string
    connection_string_secret_name = string
    create_private_endpoint     = bool
    private_link_target_resource_id = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for connection in var.sql_server_connections :
      !connection.create_private_endpoint ||
      connection.private_link_target_resource_id != null
    ])

    error_message = "SQL Server connections requiring a private endpoint must specify private_link_target_resource_id."
  }
}

variable "postgresql_connections" {
  description = "PostgreSQL connections represented by Key Vault secret names."
  type = list(object({
    name                        = string
    connection_string_secret_name = string
    create_private_endpoint     = bool
    private_link_target_resource_id = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for connection in var.postgresql_connections :
      !connection.create_private_endpoint ||
      connection.private_link_target_resource_id != null
    ])

    error_message = "PostgreSQL connections requiring a private endpoint must specify private_link_target_resource_id."
  }
}

variable "storage_account_connections" {
  type = list(object({
    name                            = string
    description                     = optional(string)
    connection_string_secret_name   = optional(string)
    storage_account_name            = optional(string)
    use_managed_identity            = optional(bool, true)
    use_private_link                = optional(bool, false)
    private_link_target_resource_id = optional(string)
    private_link_subresource_name   = optional(string, "blob")
  }))

  default     = []
  description = "List of Azure Storage linked service definitions."

  validation {
    condition = alltrue([
      for connection in var.storage_account_connections : connection.connection_string_secret_name != null || connection.storage_account_name != null
    ])
    error_message = "Each storage_account_connections entry must provide connection_string_secret_name, or storage_account_name."
  }
}
