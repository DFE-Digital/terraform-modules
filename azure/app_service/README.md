# Azure Managed Redis

Terraform code for deploying an Azure Web App or Function App, App Service.

## Terraform documentation

For the list of requirements, inputs, outputs and resources, check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
```

### Monitoring

If `azure_enable_monitoring` is `true`, it’s expected that the following resources already exist:

- A resource group named `${azure_resource_prefix}-${service_short}-mn-rg` (where `mn` stands for monitoring and `rg` stands for resource group).
- A monitor action group named `${azure_resource_prefix}-${service_name}` within the above resource group.

## Outputs
