# StatusCake monitoring

Terraform code for deploying StatusCake uptime and SSL checks.

## Usage

```terraform
module "statuscake" {
  count = var.enable_statuscake ? 1 : 0

  source = "git::https://github.com/DFE-Digital/terraform-modules.git//monitoring/statuscake?ref=stable"

  uptime_urls = [module.web_application.probe_url, "https://#{var.external_hostname}"]
  ssl_urls    = ["https://#{var.external_hostname}"]

  contact_groups = var.statuscake_contact_groups
}
```
