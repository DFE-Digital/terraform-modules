# Azure App Service Plan Module

Terraform code for deploying an Azure App Service Plan.

## Terraform documentation

For the list of requirements, inputs, outputs and resources, check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "app_service_plan" {
  source = "./vendor/modules/azure//azure/app_service_plan"

  subscription_short = "s158"
  env_short          = var.env_short
  service_short      = "gias"
  config_short       = var.config_short
  web_app_name       = "edubase"
  sp_sku_name        = "S3"
}
```

The generated plan name follows the existing App Service naming convention. Set `sp_name` to override it.

Pass the plan output to the App Service module using `service_plan_id = module.app_service_plan.id`.
