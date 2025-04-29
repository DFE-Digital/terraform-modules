# K8S Job Configuration

Terraform code for creation for a k8s job - useful for initialisation tasks such as db-migrations etc

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "job_configuration" {
  source = "./vendor/modules/aks//aks/job_configuration"

  namespace              = var.namespace
  environment            = var.environment
  service_name           = var.service_name
  docker_image           = var.docker_image
  commands               = var.commands
  arguments              = var.arguments
  job_name               = var.job_name

    config_map_ref = module.application_configuration.kubernetes_config_map_name
    secret_ref     = module.application_configuration.kubernetes_secret_name
    cpu            = module.cluster_data.configuration_map.cpu_min
}
```

## Outputs

N/A