variable "hosted_zone" {
  type = map(any)
}

variable "deploy_default_records" {
  nullable = false
  type     = bool
  default  = true
}

variable "tags" {
  default = null
}

variable "azure_enable_monitoring" {
  nullable    = false
  type        = bool
  description = "Enable monitoring and logging in Azure"
  default     = false
}

variable "single_policy" {
  type        = bool
  nullable    = false
  default     = false
  description = "Use a single policy instead of one per env"
}

locals {
  default_records = {
    "caa_record_list" = ["globalsign.com", "digicert.com"],
    "txt_records" = {
      "@" = {
        "value" = "v=spf1 -all"
      },
      "_dmarc" = {
        "value" = "v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk; ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"
      }
    }
  }

  hosted_zone_with_records = { for zone_name, zone_cfg in var.hosted_zone :
    zone_name => merge(zone_cfg, var.deploy_default_records ? local.default_records : null)
  }

  firewall_policy_suffix = azurerm_cdn_frontdoor_profile.main[0].sku_name == "Premium_AzureFrontDoor" ? "Premium" : ""

  # If true, removes .gov.uk and replaces remaining period with a hyphen e.g. 'domain.education.gov.uk' becomes domain-edu.
  # We shorten the zone name as the fd endpoint name can only be a maximum of 46 chars
  # This works around an issue where two front doors in the same resource group can't have an endpoint with the same name.
  # If false, removes anything after the first full stop/period e.g. 'domain.education.gov.uk' becomes just 'domain'.
  # short_zone_name    = substr(replace(var.zone, "/^[^.]+\\./", ""), 0, 3)
  # endpoint_zone_name = var.multiple_hosted_zones ? replace(var.zone, "/\\..+$/", "-${local.short_zone_name}") : replace(var.zone, "/\\..+$/", "")

  # # firewall policy names must be unique within the resource group, and consist of letters and numbers only
  # short_policy_name_prefix = substr(replace(local.endpoint_zone_name, "-", ""), 0, 10)
  # short_policy_name        = "${local.short_policy_name_prefix}${local.short_zone_name}"


}
