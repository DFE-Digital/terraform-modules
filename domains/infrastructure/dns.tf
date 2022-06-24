module "dns" {
  source      = "git::https://github.com/DFE-Digital/terraform-modules.git//dns/zones"
  hosted_zone = local.hosted_zone_with_records
  tags        = var.tags
}
