
variable "azure_credentials" { default = null }

variable "hosted_zone" {
  type    = map(any)
  default = {}
}

variable "tags" {
  default = null
}

locals {
  azure_credentials = try(jsondecode(var.azure_credentials), null)
}
