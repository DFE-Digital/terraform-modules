variable "front_door_name" {
  description = "Name of the shared Front Door profile"
  type        = string
}

variable "hosted_zones" {
  description = "Map of DNS zones to manage"
  type = map(object({
    zone_name              = string
    resource_group_name    = string
    deploy_default_records = optional(bool, true)
    caa_record_list        = optional(list(string), ["globalsign.com", "digicert.com"])
    txt_records = optional(map(object({
      value = string
    })), {})
  }))
}

variable "resource_group_name" {
  description = "Resource group for Front Door resources"
  type        = string
}

variable "azure_enable_monitoring" {
  description = "Enable Azure monitoring and diagnostics"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

locals {
  default_records = {
    txt_records = {
      "@" = {
        value = "v=spf1 -all"
      }
      "_dmarc" = {
        value = "v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk; ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"
      }
    }
  }

  # Merge default records with zone configuration
  hosted_zones_with_records = {
    for zone_key, zone_cfg in var.hosted_zones :
    zone_key => merge(
      zone_cfg,
      zone_cfg.deploy_default_records ? {
        txt_records = merge(
          local.default_records.txt_records,
          zone_cfg.txt_records
        )
      } : {}
    )
  }
}