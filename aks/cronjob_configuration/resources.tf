locals {
  logit_annotations = var.enable_logit ? {
    "logit.io/send"        = "true"
    "fluentbit.io/exclude" = "true"
  } : {}

  gcp_wif_label = var.enable_gcp_wif ? {
    "azure.workload.identity/use" = "true"
  } : {}
}

resource "kubernetes_config_map" "cmap" {
  for_each = var.cm_mount

  metadata {
    name      = "${each.key}${var.environment}cronjob-configmap"
    namespace = var.namespace
  }

  data = {
    "command.sh" = "test"
  }

}

resource "kubernetes_cron_job" "main" {
  metadata {
    name      = "${var.service_name}-${var.environment}-${var.job_name}"
    namespace = var.namespace
  }

  spec {
    concurrency_policy            = "Replace"
    #failed_jobs_history_limit     = 5 # default 1
    schedule                      = "${var.schedule}"
    #timezone                      = "Etc/UTC" # vscode says unexpected
    starting_deadline_seconds     = 10
    #successful_jobs_history_limit = 10 # default 3
    job_template {
      metadata {
        # labels      = merge({ app = "${var.service_name}-${var.environment}-${var.job_name}" }, local.gcp_wif_label)
        # annotations = local.logit_annotations
      }

      spec {
        backoff_limit = 0
        #ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            service_account_name = var.enable_gcp_wif ? "gcp-wif" : null
            container {
              name    = var.job_name
              image   = var.docker_image
              command = var.commands
              args    = var.arguments

              # volume_mount {
              #   name       = "airbyte-sql"
              #   mount_path = "/airbyte"
              # }

              dynamic "volume_mount" {
                for_each = var.cm_mount
                content {
                  name = var.value.name
                  mount_path = var.value.mount_path
                }
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
                  memory = var.max_memory
                }
                limits = {
                  cpu    = 1
                  memory = var.max_memory
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
            restart_policy = "Never"
            # volume {
            #   name = "airbyte-sql"
            #   secret {
            #     secret_name = kubernetes_secret.airbyte-sql.metadata[0].name
            #     }
            #   }

            dynamic "volume" {
              for_each = var.cm_mount
              content {
                name = var.value.name
                config_map {
                  name = kubernetes_config_map.cronjob.metadata[0].name
                }
              }
            }

          }
        }
      }
    }
  }
}
