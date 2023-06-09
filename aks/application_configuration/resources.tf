locals {
  config_map_data = merge(
    try(yamldecode(file(var.config_variables_path)), {}),
    var.config_variables,
  )

  config_map_hash = sha1(join("-", [for k, v in local.config_map_data : "${k}:${v}"]))
}

resource "kubernetes_config_map" "main" {
  metadata {
    name      = "${var.service_short}-${var.environment}-${local.config_map_hash}"
    namespace = var.namespace
  }

  data = local.config_map_data
}

locals {
  secret_hash = sha1(join("-", [for k, v in var.secret_variables : "${k}:${v}" if v != null]))
}

resource "kubernetes_secret" "main" {
  metadata {
    name      = "${var.service_short}-${var.environment}-${local.secret_hash}"
    namespace = var.namespace
  }

  data = var.secret_variables
}
