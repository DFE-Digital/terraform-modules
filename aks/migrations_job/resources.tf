locals {
  logit_annotations = var.enable_logit ? {
    "logit.io/send"        = "true"
    "fluentbit.io/exclude" = "true"
  } : {}
}

resource "kubernetes_job" "main" {
  metadata {
    name      = "${var.service_name}-${var.environment}-${var.job_name}"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {
        labels      = { app = "${var.service_name}-${var.environment}-${var.job_name}" }
        annotations = local.logit_annotations
      }



      spec {
        container {
          name    = var.job_name
          image   = var.docker_image
          command = var.commands
          args    = var.arguments
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
