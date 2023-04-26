locals {
  app_name = "${var.name}-${var.app_environment}"
}

resource "kubernetes_deployment" "main" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = local.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.app_name
        }
      }

      spec {
        node_selector = {
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }

        container {
          name    = local.app_name
          image   = var.docker_image
          command = try(slice(var.command, 0, 1), null)
          args    = try(slice(var.command, 1, length(var.command)), null)

          liveness_probe {
            http_get {
              path = "/check"
              port = 3000
            }

            failure_threshold = 10
            period_seconds    = 1
            timeout_seconds   = 10
          }

          startup_probe {
            http_get {
              path = "/check"
              port = 3000
            }

            failure_threshold = 24
            period_seconds    = 5
          }

          env_from {
            config_map_ref {
              name = var.kubernetes_config_map_name
            }
          }

          env_from {
            secret_ref {
              name = var.kubernetes_secret_name
            }
          }

          resources {
            requests = {
              cpu    = var.cluster_configuration_map.cpu_min
              memory = var.max_memory
            }
            limits = {
              cpu    = 1
              memory = var.max_memory
            }
          }

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "main" {
  count = var.is_web ? 1 : 0

  metadata {
    name      = local.app_name
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 3000
    }
    selector = {
      app = local.app_name
    }
  }
}

locals {
  host_name  = var.cluster_configuration_map.dns_zone_prefix != null ? "${local.app_name}.${var.cluster_configuration_map.dns_zone_prefix}.teacherservices.cloud" : "${local.app_name}.teacherservices.cloud"
  hostnames = var.is_web ? concat([local.host_name], var.external_hostnames) : []
}

resource "kubernetes_ingress_v1" "main" {
  for_each = toset(local.hostnames)

  wait_for_load_balancer = true

  metadata {
    name      = local.app_name
    namespace = var.namespace
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = each.value
      http {
        path {
          backend {
            service {
              name = kubernetes_service.main[0].metadata[0].name
              port {
                number = kubernetes_service.main[0].spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}
