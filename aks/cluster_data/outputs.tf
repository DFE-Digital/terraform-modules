output "configuration_map" {
  value = local.configuration_map
}

output "kubernetes_host" {
  value = data.azurerm_kubernetes_cluster.main.kube_config.0.host
}

output "kubernetes_id" {
  value = data.azurerm_kubernetes_cluster.main.id
}

output "kubernetes_client_certificate" {
  value = (local.azure_RBAC_enabled ? null :
    base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  )
}

output "kubernetes_client_key" {
  value = (local.azure_RBAC_enabled ? null :
    base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  )
  sensitive = true
}

output "kubernetes_cluster_ca_certificate" {
  value = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

output "ingress_domain" {
  value = "${local.dns_zone_prefix_with_optional_dot}teacherservices.cloud"
}

output "kubelogin_args" {
  description = "Kubelogin arguments to use configure the kubernetes provider. Allows workload identity, service principal secret and azure cli"
  # If running in github actions, AAD_LOGIN_METHOD determines the login method, either workloadidentity or spn
  # If not, use azurecli explicitly as command line argument
  value = (local.running_in_github_actions ?
    local.kubelogin_github_actions_args :
    local.kubelogin_azurecli_args
  )
}
output "azure_RBAC_enabled" {
  value = local.azure_RBAC_enabled
}
