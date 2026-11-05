# Azure App Service Module

Terraform code for deploying an Azure Web App or Function App, App Service.

- Azure Web Apps
- Azure Function Apps
- Deployment Slots (optional)
- Diagnostic Settings (optional)

## Features

- Supports Windows Web Apps
- Supports Windows Function Apps
- Shared or dedicated App Service Plans
- Managed Identity support
- Application settings

## Terraform documentation

For the list of requirements, inputs, outputs and resources, check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "edubase_app_service_plan" {
  source = "./vendor/modules/azure//azure/app_service_plan"

  subscription_short = "s158"
  env_short          = var.env_short
  service_short      = "gias"
  config_short       = var.config_short
  web_app_name       = "edubase"
  sp_sku_name        = "S3"
}

module "edubase_web_app" {
  source = "./vendor/modules/azure//azure/app_service"

  app_type           = "web"
  service_plan_id    = module.edubase_app_service_plan.id
  web_app_name       = "edubase"
  subscription_short = "s158"
  env_short          = var.env_short
  environment        = var.environment
  service_name       = var.service_name
  service_short      = "gias"
  config_short       = var.config_short
  logs = {
    http_logs = {
      file_system = {
        retention_in_days = 0
        retention_in_mb   = 35
      }
    }
  }
  application_stack = {
    dotnet_version = "v4.0"
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                    = ""
    APPINSIGHTS_PROFILERFEATURE_VERSION               = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION               = "1.0.0"
  }
  sticky_app_settings = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
    ]
  slots = {
    staging = {}
  }
}
```

### Monitoring

If `azure_enable_monitoring` is `true`, it’s expected that the following resources already exist:

- A resource group named `${azure_resource_prefix}-${service_short}-mn-rg` (where `mn` stands for monitoring and `rg` stands for resource group).
- A monitor action group named `${azure_resource_prefix}-${service_name}` within the above resource group.

## Notes

- Function Apps require a Storage Account.
- Deployment slots are supported for Web Apps and Premium Function Apps.
- Managed Identity can be used for Azure resource authentication.
- When moving from the previous combined module, move the plan state to the new module address to avoid recreating it. For example, adapt this root-module block to your module names:

  ```terraform
  moved {
    from = module.edubase_web_app.azurerm_service_plan.main
    to   = module.edubase_app_service_plan.azurerm_service_plan.main
  }
  ```
