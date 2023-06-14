output "hostname" {
  value = local.hostname
}

output "url" {
  value = "https://${local.hostname}"
}

output "probe_url" {
  value = var.probe_path != null ? "https://${local.hostname}${var.probe_path}" : null
}
