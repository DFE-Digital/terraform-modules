locals {
  create_postgres = var.enable_postgres && (var.postgres_subnet != null ? length(var.postgres_subnet) > 0 : false)
  create_sql      = var.enable_sql && (var.sql_subnet != null ? length(var.sql_subnet) > 0 : false)
  create_redis    = var.enable_redis && (var.redis_subnet != null ? length(var.redis_subnet) > 0 : false)
  create_apps     = var.enable_apps && (var.apps_subnet != null ? length(var.apps_subnet) > 0 : false)
  create_storage  = var.enable_storage && (var.storage_subnet != null ? length(var.storage_subnet) > 0 : false)
}
