resource "kubernetes_deployment" "main_worker" {
  for_each = var.worker_apps

  metadata {
    name      = "${var.service_name}-${each.key}-${var.app_environment}"
    namespace = var.namespace
  }
  spec {
    replicas = each.value.replicas
    selector {
      match_labels = {
        app = "${var.service_name}-${each.key}-${var.app_environment}"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "${var.service_name}-${each.key}-${var.app_environment}"
        }
      }
      spec {
        node_selector = {
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }
        container {
          name    = "${var.service_name}-${each.key}-${var.app_environment}"
          image   = var.app_docker_image
          command = try(slice( each.value.startup_command, 0, 1 ), null)
          args    = try(slice( each.value.startup_command, 1, length(each.value.startup_command) ), null)

          # Check performed to ensure the application is available. If it fails the current pod is killed and a new one created.
          dynamic "liveness_probe" {
            for_each = each.value.probe_path

            content {
              exec {
                command = [ join(",", each.value["probe_path"]) ]
              }
              period_seconds = 10
            }
          }

          dynamic "startup_probe" {
            for_each = each.value.probe_path

            content {
              exec {
                command = [ join(",", each.value["probe_path"]) ]
              }
              initial_delay_seconds = 5
              period_seconds        = 10
              }
            }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata.0.name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.app_secrets.metadata.0.name
            }
          }
          resources {
            requests = {
              cpu    = local.current_cluster.cpu_min
              memory = each.value.memory_max
            }
            limits = {
              cpu    = 1
              memory = each.value.memory_max
            }
          }
        }
      }
    }
  }
}
