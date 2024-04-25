# Environment domains

Create all domains for an environment. This includes the DNS records and the front door resources.

By default a single frontdoor works for a single DNS zone. When adding more zones, use the add_to_front_door variable.

## Usage

```terraform
module "domains" {
  source              = "git::https://github.com/DFE-Digital/terraform-modules.git//domains/environment_domains"
  zone                = var.zone1
  front_door_name     = var.front_door_name
  resource_group_name = var.resource_group_name
  domains             = var.domains1
  environment         = var.environment_short
  host_name           = var.origin_hostname1
}

module "additional_domains" {
  source              = "git::https://github.com/DFE-Digital/terraform-modules.git//domains/environment_domains"
  zone                = var.zone2
  add_to_front_door   = var.front_door_name
  resource_group_name = var.resource_group_name
  domains             = var.domains2
  environment         = var.environment_short
  host_name           = var.origin_hostname2
}
```
