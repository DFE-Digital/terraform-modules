#CREATE istio VirtualService for web applications - istio.enabled="true"

locals {
  istio_hostname  = var.cluster_configuration_map.istiio_dns_zone_prefix != null ? "${local.istio_app_name}.${var.cluster_configuration_map.istio_dns_zone_prefix}.teacherservices.cloud" : "${local.istio_app_name}.teacherservices.cloud"
  istio_hostnames = var.is_web ? concat([local.hostname], var.web_external_hostnames) : []

  istio_name_suffix = var.name != null ? "-${var.name}" : ""
  istio_app_name    = "${var.service_name}-${var.environment}${local.istio_name_suffix}"

 istio_dns_zone_prefix = (
    try(var.cluster_configuration_map.dns_zone_prefix, null) != null
    ? "istio${var.cluster_configuration_map.dns_zone_prefix}"
    : null
  )

}

resource "kubernetes_manifest" "istio_virtual_service" {
  for_each = var.istio_enabled ? toset(local.istio_hostnames) : toset([])

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "vs-${replace(each.value, ".", "-")}"
      namespace = var.namespace
    }

    spec = {
      hosts    = [each.value]
      gateways = [
        "istio-ingress/istio-ingress-gateway"
        ]

      http = [
        {
          match = [
            {
              uri = { prefix = "/" }
            }
          ]
          route = [
            {
                destination = {
                host = var.send_traffic_to_maintenance_page ? "${var.service_name}-maintenance" : kubernetes_service.main[0].metadata[0].name

                port = {
                number = var.send_traffic_to_maintenance_page ? local.maintenance_service_port : kubernetes_service.main[0].spec[0].port[0].port
                }
              } 
            }
          ]
        }
      ]
    }
  }
}
