locals {
  name_suffix = var.name != null ? "-${var.name}" : ""
  app_name    = "${var.service_name}-${var.environment}${local.name_suffix}"

  http_probe_enabled = var.is_web && var.probe_path != null
  exec_probe_enabled = !var.is_web && length(var.probe_command) != 0
  probe_enabled      = local.http_probe_enabled || local.exec_probe_enabled
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
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "topology.kubernetes.io/zone"
          when_unsatisfiable = "DoNotSchedule"
          label_selector {
            match_labels = {
              app = local.app_name
            }
          }
        }
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"
          label_selector {
            match_labels = {
              app = local.app_name
            }
          }
        }

        container {
          name    = local.app_name
          image   = var.docker_image
          command = try(slice(var.command, 0, 1), null)
          args    = try(slice(var.command, 1, length(var.command)), null)

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

          dynamic "port" {
            for_each = var.is_web ? ["this"] : []
            content {
              container_port = var.web_port
            }
          }

          dynamic "liveness_probe" {
            for_each = local.probe_enabled ? ["this"] : []

            content {
              dynamic "http_get" {
                for_each = local.http_probe_enabled ? ["this"] : []
                content {
                  path = var.probe_path
                  port = var.web_port
                }
              }

              dynamic "exec" {
                for_each = local.exec_probe_enabled ? ["this"] : []
                content {
                  command = var.probe_command
                }
              }

              failure_threshold = 10
              period_seconds    = 1
              timeout_seconds   = 10
            }
          }

          dynamic "startup_probe" {
            for_each = local.probe_enabled ? ["this"] : []
            content {
              dynamic "http_get" {
                for_each = local.http_probe_enabled ? ["this"] : []
                content {
                  path = var.probe_path
                  port = var.web_port
                }
              }

              dynamic "exec" {
                for_each = local.exec_probe_enabled ? ["this"] : []
                content {
                  command = var.probe_command
                }
              }

              failure_threshold = 24
              period_seconds    = 5
            }
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
  hostname  = var.cluster_configuration_map.dns_zone_prefix != null ? "${local.app_name}.${var.cluster_configuration_map.dns_zone_prefix}.teacherservices.cloud" : "${local.app_name}.teacherservices.cloud"
  hostnames = var.is_web ? concat([local.hostname], var.web_external_hostnames) : []
}

resource "kubernetes_ingress_v1" "main" {
  for_each = toset(local.hostnames)

  wait_for_load_balancer = true

  metadata {
    name      = each.value
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

resource "kubernetes_pod_disruption_budget_v1" "main" {
  count = var.replicas > 1 ? 1 : 0

  metadata {
    name      = local.app_name
    namespace = var.namespace
  }
  spec {
    min_available = "50%"
    selector {
      match_labels = {
        app = local.app_name
      }
    }
  }
}

locals {
  statuscake_enabled   = local.http_probe_enabled && var.enable_statuscake
  statuscake_hostnames = local.statuscake_enabled ? local.hostnames : []
}

resource "statuscake_uptime_check" "main" {
  for_each = local.statuscake_hostnames

  name           = each.value
  contact_groups = var.statuscake_contact_groups
  confirmation   = 2
  trigger_rate   = 0
  check_interval = 30
  regions        = ["london", "dublin"]

  http_check {
    follow_redirects = true
    timeout          = 40
    request_method   = "HTTP"
    status_codes     = ["204", "205", "206", "303", "400", "401", "403", "404", "405", "406", "408", "410", "413", "444", "429", "494", "495", "496", "499", "500", "501", "502", "503", "504", "505", "506", "507", "508", "509", "510", "511", "521", "522", "523", "524", "520", "598", "599"]
    validate_ssl     = false
  }

  monitored_resource {
    address = "https://${each.value}${var.probe_path}"
  }
}
