locals {
  create_vnet     = var.vnet_address != null ? length(var.vnet_address) > 0 : false
  create_postgres = local.create_vnet && var.enable_postgres && (var.postgres_subnet != null ? length(var.postgres_subnet) > 0 : false)
  create_sql      = local.create_vnet && var.enable_sql && (var.sql_subnet != null ? length(var.sql_subnet) > 0 : false)
  create_redis    = local.create_vnet && var.enable_redis && (var.redis_subnet != null ? length(var.redis_subnet) > 0 : false)
  create_apps     = local.create_vnet && var.enable_apps && (var.apps_subnet != null ? length(var.apps_subnet) > 0 : false)
  create_storage  = local.create_vnet && var.enable_storage && (var.storage_subnet != null ? length(var.storage_subnet) > 0 : false)
}
