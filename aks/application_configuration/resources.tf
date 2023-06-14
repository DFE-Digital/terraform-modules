locals {
  rails_config_map_data = {
    RAILS_SERVE_STATIC_FILES = "true",
    RAILS_LOG_TO_STDOUT      = "true"
  }

  config_map_data = merge(
    var.is_rails_application ? local.rails_config_map_data : {},
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

module "secret_application" {
  source = "../secret"

  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  name    = var.key_vault_secret_name
  is_yaml = true
}

locals {
  secret_data = merge(
    module.secret_application.value,
    var.secret_variables,
  )

  secret_hash = sha1(join("-", [for k, v in local.secret_data : "${k}:${v}" if v != null]))
}

resource "kubernetes_secret" "main" {
  metadata {
    name      = "${var.service_short}-${var.environment}-${local.secret_hash}"
    namespace = var.namespace
  }

  data = local.secret_data
}
