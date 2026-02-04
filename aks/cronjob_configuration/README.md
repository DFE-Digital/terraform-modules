# K8S Cron Job Configuration

Terraform code for creation for a k8s cron job - useful for running scheduled tasks

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "cronjob_configuration" {
  source = "./vendor/modules/aks//aks/cronjob_configuration"

  namespace              = var.namespace
  environment            = var.environment
  service_name           = var.service_name
  docker_image           = var.docker_image
  commands               = var.commands
  arguments              = var.arguments
  job_name               = var.job_name
  enable_logit           = var.enable_logit

    config_map_ref = module.application_configuration.kubernetes_config_map_name
    secret_ref     = module.application_configuration.kubernetes_secret_name
    cpu            = module.cluster_data.configuration_map.cpu_min
}
```

## Outputs

N/A
