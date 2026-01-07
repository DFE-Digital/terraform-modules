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

variable "host_name" {
  type        = string
  description = "Host name"
}

variable "database_name" {
  type        = string
  description = "database name"
}

variable "repl_password" {
  type        = string
  description = "Password of the replication user"
  sensitive   = true
  default     = null
}

variable "workspace_id" {
  type        = string
  description = "Airbyte workspace id"
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

variable "config_map_ref" {
  description = "formerly: module.application_configuration.kubernetes_config_map_name"
  type        = string
}

variable "secret_ref" {
  description = "formerly: module.application_configuration.kubernetes_secret_name"
  type        = string
}

variable "cpu" {
  description = "formerly: module.cluster_data.configuration_map.cpu_min"
  type        = string
}

variable "docker_image" {
  type        = string
  description = "Current application environment"
}

variable "postgres_version" {
  type        = string
  description = "postgres version"
}

variable "postgres_url" {
  type        = string
  sensitive   = true
  description = "Postgres connection url"
}

variable "client_id" {
  type        = string
  sensitive   = true
  description = "Airbyte client id"
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Airbyte client secret"
}

variable "use_azure" {
  type        = bool
  description = "Whether to deploy using Azure Postgres"
}

locals {
  source_name      = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-pg-source"
  destination_name = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-bq-destination"
  connection_name  = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-airbyte-conn"

  cron_expression = var.schedule_type == "cron" ? "0 */15 * * * ? UTC" : null # Cron schedule for syncs every hour on the hour

  original_repl_password = var.repl_password != null ? var.repl_password : random_password.password[0].result
  # Remove sequences of multiple dollar signs. Fix setting up the database password
  # on the container as we use a shell environment variable for that
  replication_password = replace(local.original_repl_password, "/\\$+/", "$")

  template_variable_map = {
    repl_password = local.replication_password
    database_name = var.database_name
  }

  source_id = var.use_azure == true ? airbyte_source_postgres.source_postgres[0].source_id : airbyte_source_postgres.source_postgres_container[0].source_id

  sqlCommand      = templatefile("${path.module}/files/airbyte.sql.tmpl", local.template_variable_map)
  sql_secret_hash = substr(sha1("${local.sqlCommand}"), 0, 12)
}
