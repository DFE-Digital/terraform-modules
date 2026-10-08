locals {
  resource_prefix     = "${var.subscription_short}${var.env_short}"
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : "${local.resource_prefix}-${var.service_short}-${var.config_short}-rg"
}
