locals {
  database_name = "${var.service_short}_${var.environment}"

  source_name      = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-pg-source"
  destination_name = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-bq-destination"
  connection_name  = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-airbyte-conn"

  cron_expression = var.schedule_type == "cron" ? "0 */15 * * * ? Europe/London" : null # Cron schedule for syncs every hour on the hour

  original_repl_password = var.repl_password != null ? var.repl_password : random_password.password[0].result
  # Remove sequences of multiple dollar signs. Fix setting up the database password
  # on the container as we use a shell environment variable for that
  replication_password = replace(local.original_repl_password, "/\\$+/", "$")
}

resource "random_password" "password" {
  count = var.repl_password == null ? 1 : 0

  length  = 32
  special = true
}

resource "airbyte_source_postgres" "source_postgres" {
  count = var.use_airbyte ? 1 : 0

  name         = local.source_name
  workspace_id = var.workspace_id

  configuration = {
    host     = var.host_name
    port     = 5432
    database = var.database_name
    username = var.repl_user
    password = local.replication_password

    ssl_mode = {
      require = {}
    }
    tunnel_method = {
      no_tunnel = {}
    }
    replication_method = {
      read_changes_using_write_ahead_log_cdc = {
        replication_slot = "airbyte_slot"
        publication      = "airbyte_publication"
        plugin           = "pgoutput"
        initial_snapshot = true
      }
    }
  }

}

resource "airbyte_destination_bigquery" "destination_bigquery" {
  count = var.use_airbyte ? 1 : 0

  name         = local.destination_name
  workspace_id = var.workspace_id

  configuration = {
    project_id       = var.project_id
    dataset_id       = var.dataset_id
    dataset_location = "europe-west2"
    credentials_json = var.credentials_json

    loading_method = {
      batched_standard_inserts = {}
    }
  }

}

resource "airbyte_connection" "connection" {
  count = var.use_airbyte ? 1 : 0

  name           = local.connection_name
  source_id      = airbyte_source_postgres.source_postgres[0].source_id
  destination_id = airbyte_destination_bigquery.destination_bigquery[0].destination_id

  non_breaking_schema_updates_behavior = "propagate_fully"

  status = var.connection_status

  schedule = {
    cron_expression = local.cron_expression
    schedule_type   = var.schedule_type
  }

}
