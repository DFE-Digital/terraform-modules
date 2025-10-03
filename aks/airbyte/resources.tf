resource "random_password" "password" {
  count = var.repl_password == null ? 1 : 0

  length  = 32
  special = true
}

resource "airbyte_source_postgres" "source_postgres" {
  count = var.use_azure == true ? 1 : 0

  depends_on = [kubernetes_job.airbyte-database-setup]

  name         = local.source_name
  workspace_id = var.workspace_id

  configuration = {
    host     = var.host_name
    port     = 5432
    database = var.database_name
    username = "airbyte_replication"
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

resource "airbyte_source_postgres" "source_postgres_container" {
  count = var.use_azure == true ? 0 : 1

  depends_on = [kubernetes_job.airbyte-database-setup]

  name         = local.source_name
  workspace_id = var.workspace_id

  configuration = {
    host     = var.host_name
    port     = 5432
    database = var.database_name
    username = "airbyte_replication"
    password = local.replication_password

    ssl_mode = {
      disable = {}
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
  depends_on = [google_bigquery_dataset.main, google_bigquery_dataset_iam_member.appender, google_bigquery_dataset_iam_member.appender_internal]

  name         = local.destination_name
  workspace_id = var.workspace_id

  configuration = {
    project_id       = data.google_project.main.project_id
    dataset_id       = local.gcp_dataset_name
    dataset_location = "europe-west2"
    credentials_json = local.gcp_credentials

    loading_method = {
      batched_standard_inserts = {}
    }
  }
}

resource "airbyte_connection" "connection" {
  name           = local.connection_name
  source_id      = var.use_azure == true ? airbyte_source_postgres.source_postgres[0].source_id : airbyte_source_postgres.source_postgres_container[0].source_id
  destination_id = airbyte_destination_bigquery.destination_bigquery.destination_id

  non_breaking_schema_updates_behavior = "propagate_fully"

  status = var.connection_status

  schedule = {
    cron_expression = local.cron_expression
    schedule_type   = var.schedule_type
  }
}

module "streams_init_job" {
  source = "../job_configuration"

  depends_on = [airbyte_connection.connection]

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name
  docker_image = "ghcr.io/dfe-digital/teacher-services-cloud:curl-3.21.3"
  commands     = ["/bin/sh"]
  arguments    = ["-c", "${local.curlCommand}"]
  job_name     = "airbyte-stream-init"
  enable_logit = true

  config_map_ref = var.config_map_ref
  secret_ref     = var.secret_ref
  cpu            = var.cpu
}

module "streams_update_job" {
  source = "../job_configuration"

  depends_on = [module.streams_init_job]

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name
  docker_image = var.docker_image
  commands     = ["/bin/sh"]
  arguments    = ["-c", "rake dfe:analytics:airbyte_connection_refresh"]
  job_name     = "airbyte-stream-update"
  enable_logit = true

  config_map_ref = var.config_map_ref
  secret_ref     = var.secret_ref
  cpu            = var.cpu
}

resource "kubernetes_secret" "airbyte-sql" {
  metadata {
    name      = "${var.service_short}${var.environment}absql${local.sql_secret_hash}"
    namespace = var.namespace
  }
  data = {
    "sqlCommand.sql" = local.sqlCommand
  }
}

resource "kubernetes_job" "airbyte-database-setup" {
  depends_on = [kubernetes_secret.airbyte-sql]

  metadata {
    name      = "${var.service_name}-${var.environment}-airbyte-db-init-${kubernetes_secret.airbyte-sql.metadata[0].name}"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {
        labels = { app = "${var.service_short}-${var.environment}-ab-db-init" }
        annotations = {
          "logit.io/send"        = "true"
          "fluentbit.io/exclude" = "true"
        }
      }

      spec {
        container {
          name    = "airbyte-db-config"
          image   = "postgres:${var.postgres_version}-alpine"
          command = ["psql"]
          args    = ["-d", "${var.postgres_url}", "-f", "/airbyte/sqlCommand.sql"]

          volume_mount {
            name       = "airbyte-sql"
            mount_path = "/airbyte"
          }

          env_from {
            config_map_ref {
              name = var.config_map_ref
            }
          }

          env_from {
            secret_ref {
              name = var.secret_ref
            }
          }

          resources {
            requests = {
              cpu    = var.cpu
              memory = "1Gi"
            }
            limits = {
              cpu    = 1
              memory = "1Gi"
            }
          }

          security_context {
            allow_privilege_escalation = false

            seccomp_profile {
              type = "RuntimeDefault"
            }

            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }
        }

        volume {
          name = "airbyte-sql"
          secret {
            secret_name = kubernetes_secret.airbyte-sql.metadata[0].name
          }
        }

        restart_policy = "Never"
      }
    }

    backoff_limit = 1
  }

  wait_for_completion = true

  timeouts {
    create = "11m"
    update = "11m"
  }
}
