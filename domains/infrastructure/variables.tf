# variable "hosted_zone" {
#   type = map(any)
# }

variable "hosted_zone" {
  type = map(object({
    caa_records         = map(any)
    txt_records         = map(any)
    resource_group_name = string
    front_door_name     = string
    frontdoor_sku_name  = optional(string)
  }))
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

variable "frontdoor_sku_name" {
  description = "Default Azure Front Door SKU."
  type        = string
  default     = "Standard_AzureFrontDoor"

  validation {
    condition = contains([
      "Standard_AzureFrontDoor",
      "Premium_AzureFrontDoor"
    ], var.frontdoor_sku_name)

    error_message = "frontdoor_sku_name must be either Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
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
}
