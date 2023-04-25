output "configuration_map" {
  value = local.configuration_map
}

output "kubernetes_host" {
  value = data.azurerm_kubernetes_cluster.main.kube_config.0.host
}

output "kubernetes_client_certificate" {
  value = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
}

output "kubernetes_client_key" {
  value = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
}

output "kubernetes_cluster_ca_certificate" {
  value = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}
