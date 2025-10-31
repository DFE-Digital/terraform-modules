locals {
  name_suffix = var.name != null ? "-${var.name}" : ""
  app_name    = "${var.service_name}-${var.environment}${local.name_suffix}"

  http_probe_enabled = var.is_web && var.probe_path != null
  exec_probe_enabled = !var.is_web && length(var.probe_command) != 0
  probe_enabled      = local.http_probe_enabled || local.exec_probe_enabled

  prometheus_scrape_annotations = var.enable_prometheus_monitoring ? {
    "prometheus.io/scrape" = "true"
    "prometheus.io/path"   = "/metrics"
    "prometheus.io/port"   = var.is_web ? var.web_port : var.worker_port
  } : {}

  logit_annotations = var.enable_logit ? {
    "logit.io/send"        = "true"
    "fluentbit.io/exclude" = "true"
  } : {}

  gcp_wif_label = var.enable_gcp_wif ? {
    "azure.workload.identity/use" = "true"
  } : {}

  maintenance_service_port = 80
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

    strategy {
      type = var.is_web ? "RollingUpdate" : "Recreate"
    }

    template {
      metadata {
        labels      = merge({ app = local.app_name }, local.gcp_wif_label)
        annotations = merge(local.prometheus_scrape_annotations, local.logit_annotations)
      }

      spec {
        service_account_name            = var.enable_gcp_wif ? "gcp-wif" : null
        automount_service_account_token = false

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

        dynamic "image_pull_secrets" {
          for_each = var.github_username != null ? ["this"] : []

          content {
            name = kubernetes_secret.ghcr_auth[0].metadata[0].name
          }
        }

        container {
          name    = local.app_name
          image   = var.docker_image
          command = try(slice(var.command, 0, 1), null)
          args    = try(slice(var.command, 1, length(var.command)), null)
          working_dir = var.working_dir

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

              failure_threshold = 5
              period_seconds    = 5
              timeout_seconds   = 5
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

          security_context {
            allow_privilege_escalation = false

            seccomp_profile {
              type = "RuntimeDefault"
            }

            capabilities {
              drop = ["ALL"]
            }

            run_as_user     = var.run_as_user
            run_as_group    = var.run_as_group
            run_as_non_root = var.run_as_non_root
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
      target_port = var.web_port
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
              name = var.send_traffic_to_maintenance_page ? "${var.service_name}-maintenance" : kubernetes_service.main[0].metadata[0].name
              port {
                number = var.send_traffic_to_maintenance_page ? local.maintenance_service_port : kubernetes_service.main[0].spec[0].port[0].port
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

resource "kubernetes_secret" "ghcr_auth" {
  count = var.github_username != null ? 1 : 0

  metadata {
    name      = "ghcr-auth"
    namespace = var.namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" = {
        "https://ghcr.io" = {
          "auth" : base64encode("${var.github_username}:${var.github_personal_access_token}")
        }
      }
    })
  }
}

resource "azurerm_monitor_metric_alert" "container_restarts" {
  count = var.azure_enable_monitoring ? 1 : 0

  name                = "${local.app_name}-container-restarts"
  resource_group_name = data.azurerm_resource_group.monitoring[0].name
  scopes              = [var.kubernetes_cluster_id]
  description         = "Action will be triggered when container restarts is greater than 0"
  window_size         = "PT30M"

  criteria {
    metric_namespace = "Insights.container/pods"
    metric_name      = "restartingContainerCount"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "controllerName"
      operator = "StartsWith"
      values   = ["${local.app_name}"]
    }
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
