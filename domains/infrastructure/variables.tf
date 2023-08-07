variable "hosted_zone" {
  type = map(any)
}

variable "deploy_default_records" {
  type    = bool
  default = true
}

variable "tags" {
  default = null
}

variable "azure_enable_monitoring" {
  type        = bool
  description = "Enable monitoring and logging in Azure"
  default     = false
}


locals {
  default_records = {
    "caa_records" = {
      "@" = {
        "flags" = 0,
        "tag"   = "issue",
        "value" = "digicert.com"
      }
    }
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
