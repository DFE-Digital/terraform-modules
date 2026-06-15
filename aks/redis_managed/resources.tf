locals {
  name_suffix = var.name != null ? "-${var.name}" : ""

  azure_name                  = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-managed-redis${local.name_suffix}"
  azure_private_endpoint_name = "${var.azure_resource_prefix}-${var.service_short}-${var.environment}-managed-redis${local.name_suffix}-pe"
  azure_enable_monitoring     = var.use_azure && var.azure_enable_monitoring

  kubernetes_name = "${var.service_name}-${var.environment}-managed-redis${local.name_suffix}"

  alert_frequency_map = {
    PT5M  = "PT1M"
    PT15M = "PT1M"
    PT30M = "PT1M"
    PT1H  = "PT1M"
    PT6H  = "PT5M"
    PT12H = "PT5M"
  }
  alert_frequency = local.alert_frequency_map[var.alert_window_size]
}

# Azure Managed Redis

resource "azurerm_managed_redis" "main" {
  count = var.use_azure ? 1 : 0

  name                      = local.azure_name
  location                  = data.azurerm_resource_group.main[0].location
  resource_group_name       = data.azurerm_resource_group.main[0].name
  sku_name                  = var.azure_managed_redis_sku
  high_availability_enabled = var.managed_redis_high_availability
  public_network_access     = var.azure_public_network_access_enabled

  default_database {
    access_keys_authentication_enabled = true
    eviction_policy                    = var.azure_maxmemory_policy
    clustering_policy                  = var.db_clustering_policy
  }

  lifecycle {
    ignore_changes = [tags]
  }

  timeouts {
    create = "1h"
    update = "1h"
  }
}

# Required Private Endpoint

resource "azurerm_private_endpoint" "main" {
  count = var.use_azure ? 1 : 0

  name                = local.azure_private_endpoint_name
  location            = data.azurerm_resource_group.main[0].location
  resource_group_name = data.azurerm_resource_group.main[0].name
  subnet_id           = data.azurerm_subnet.main[0].id

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.redis_managed[0].name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.redis_managed[0].id]
  }

  private_service_connection {
    name                           = local.azure_private_endpoint_name
    private_connection_resource_id = azurerm_managed_redis.main[0].id
    is_manual_connection           = false
    subresource_names              = ["redisEnterprise"]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Alert if high memory usage

resource "azurerm_monitor_metric_alert" "memory" {
  count = local.azure_enable_monitoring ? 1 : 0

  name                = "${azurerm_managed_redis.main[0].name}-memory"
  resource_group_name = data.azurerm_resource_group.main[0].name
  scopes              = [azurerm_managed_redis.main[0].id]
  description         = "Action will be triggered when memory use is greater than ${var.azure_memory_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.Cache/redisEnterprise"
    metric_name      = "usedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_memory_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
    webhook_properties = {
      target_channels = var.service_short
      environment     = var.environment
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Kubernetes

resource "kubernetes_deployment" "main" {
  count = var.use_azure ? 0 : 1

  metadata {
    name      = local.kubernetes_name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.kubernetes_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.kubernetes_name
        }
      }
      spec {
        node_selector = {
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }
        container {
          name  = local.kubernetes_name
          image = "${var.server_docker_repo}:redis-${var.server_version}-alpine"

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "1Gi"
            }
          }
          port {
            container_port = 6379
          }

          startup_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 10
            period_seconds        = 2
            timeout_seconds       = 3
            success_threshold     = 1
            failure_threshold     = 30
          }

          liveness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 30
            period_seconds        = 5
            timeout_seconds       = 3
            success_threshold     = 1
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "time_sleep" "wait_redis_ready" {
  count = var.use_azure ? 0 : 1

  depends_on = [kubernetes_service.main]

  create_duration = "60s"
}

resource "kubernetes_service" "main" {
  count = var.use_azure ? 0 : 1

  metadata {
    name      = local.kubernetes_name
    namespace = var.namespace
  }
  spec {
    port {
      port = 6379
    }
    selector = {
      # Gets the exact label from kubernetes deployment resource to force an explicit dependency to create deployment before service
      app = kubernetes_deployment.main[0].spec[0].template[0].metadata[0].labels["app"]
    }
  }
}
