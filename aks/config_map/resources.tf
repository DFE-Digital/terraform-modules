locals {
  # config_map_data = merge(
  #   try(yamldecode(file(var.config_variables_path)), {}),
  #   try(file(var.config_file_path), {}),
  #   var.config_variables,
  # )

  config_map_hash = sha1((file(var.config_file_path)))
}

resource "kubernetes_config_map" "main" {
  metadata {
    name      = "${var.service_short}-${var.environment}-${local.config_map_hash}"
    namespace = var.namespace
  }

  data = {
    "config.yml" = file(var.config_file_path)
  }

}
