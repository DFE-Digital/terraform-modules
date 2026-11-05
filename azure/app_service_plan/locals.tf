locals {
  resource_name_prefix = "${var.subscription_short}${var.env_short}-${var.service_short}-"
  service_plan_name    = var.sp_name != null && var.sp_name != "" ? var.sp_name : "${local.resource_name_prefix}${var.config_short}-${var.sp_infix}-asp"
}
