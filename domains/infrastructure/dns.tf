module "dns" {
  source      = "../../dns/zones"
  hosted_zone = local.hosted_zone_with_records
  tags        = var.tags
}
