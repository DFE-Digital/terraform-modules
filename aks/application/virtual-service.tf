#CREATE istio VirtualService for web applications - istio.enabled="true"

resource "kubernetes_manifest" "istio_virtual_service" {
  for_each = var.istio_enabled ? toset(local.hostnames) : toset([])

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
