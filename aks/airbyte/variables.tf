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

variable "host_name" {
  type        = string
  description = "Host name"
}

variable "database_name" {
  type        = string
  description = "database name"
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

variable "repl_password" {
  type        = string
  description = "Password of the replication user"
  sensitive   = true
  default     = null
}

variable "repl_user" {
  type        = string
  description = "Name of the replication user"
  sensitive   = true
  default     = null
}

variable "use_airbyte" {
  type        = bool
  description = "Whether to deploy using Azure Redis Cache service"
  default     = false
}

variable "dataset_id" {
  type        = string
  description = "GCP dataset id"
  sensitive   = true
  default     = null
}

variable "project_id" {
  type        = string
  description = "GCP project id"
  sensitive   = true
  default     = null
}

variable "workspace_id" {
  type        = string
  description = "Airbyte workspace id"
  sensitive   = true
  default     = null
}

variable "credentials_json" {
  type        = string
  description = "Airbyte credentials json"
  sensitive   = true
  default     = null
}

variable "connection_status" {
  type        = string
  default     = null
  description = "Connectin status, either active or inactive"
}

variable "schedule_type" {
  type        = string
  default     = "cron"
  description = "Connection schedule type, either manual or cron. Cron will run on hourly schedule"
}

variable "server_url" {
  type        = string
  default     = null
  sensitive   = true
  description = "Server url"
}
