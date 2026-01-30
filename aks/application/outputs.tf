output "hostname" {
  value = local.hostname
}

output "url" {
  value = "https://${local.hostname}"
}

output "probe_url" {
  value = var.probe_path != null ? "https://${local.hostname}${var.probe_path}" : null
}

#ISTIO Virtual Service Hostnames
#output "istio_hostnames" {
#  value = var.istio_enabled ? local.istio_hostname : []
}

#output "istio_url" {
#  value = var.istio_enabled ? "https://${local.istio_hostname}" : []
#}