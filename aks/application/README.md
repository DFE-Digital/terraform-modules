# AKS Application

Terraform code for deploying an application.

## Usage

```terraform
module "aks_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=x.x.x"

  name   = "web"
  is_web = true
  
  namespace           = var.namespace
  app_environment     = var.app_environment
  resource_group_name = var.resource_group_name

  cluster_configuration_map = module.aks_cluster_data.configuration_map
  
  kubernetes_config_map_name = module.aks_application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.aks_application_configuration.kubernetes_secret_name
  
  docker_image       = ""
  command            = []
  external_hostnames = []
  max_memory         = 512
}
```

## Outputs

### `hostname`

The hostname of the deployed application.
