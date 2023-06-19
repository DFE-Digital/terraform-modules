# Example Rails deployment

## Minimum requirements

### Variables

```terraform
variable "app_environment" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
}

variable "azure_resource_prefix" {
  type = string
}

variable "azure_sp_credentials_json" {
  type    = string
  default = null
}

variable "cluster" {
  type = string
}

variable "config_short" {
  type = string
}

variable "deploy_azure_backing_services" {
  type    = string
  default = true
}

variable "docker_image" {
  type = string
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "external_hostname" {
  type    = string
  default = null
}

variable "namespace" {
  type = string
}

variable "service_short" {
  type = string
}
```

### Environments

#### Development

```json
{
  "app_environment": "development",
  "cluster": "test",
  "enable_monitoring": false,
  "external_hostname": "dev.service.england.education.gov.uk",
  "namespace": "tra-development"
}
```

#### Test

```json
{
  "app_environment": "test",
  "cluster": "test",
  "enable_monitoring": false,
  "external_hostname": "test.service.education.gov.uk",
  "namespace": "tra-test"
}
```

#### Review

```json
{
  "app_environment": "review",
  "cluster": "test",
  "deploy_azure_backing_services": false,
  "enable_monitoring": false,
  "namespace": "tra-development"
}
```

#### Pre-production

```json
{
  "app_environment": "preproduction",
  "cluster": "test",
  "enable_monitoring": false,
  "external_hostname": "preprod.service.education.gov.uk",
  "namespace": "tra-test"
}
```

#### Production

```json
{
  "app_environment": "production",
  "cluster": "production",
  "enable_monitoring": true,
  "external_hostname": "service.education.gov.uk",
  "namespace": "tra-production"
}
```

### Terraform configuration and providers

```terraform
terraform {
  required_version = "1.4.5"

  backend "azurerm" {}
}

locals {
  azure_credentials = try(jsondecode(var.azure_sp_credentials_json), null)
}

provider "azurerm" {
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
  skip_provider_registration = true

  features {}
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  client_certificate     = module.cluster_data.kubernetes_client_certificate
  client_key             = module.cluster_data.kubernetes_client_key
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate
}
```

### Locals

```terraform
locals {
  environment  = "${var.app_environment}${var.app_suffix}"
  service_name = "service-name"
}
```

### Cluster data

```terraform
module "cluster_data" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/cluster_data?ref=stable"
  name   = var.cluster
}
```

### Redis database

```terraform
module "redis" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/redis?ref=stable"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = local.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
}
```

### PostgreSQL database

```terraform
module "postgres" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/postgres?ref=stable"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_name          = local.service_name
  service_short         = var.service_short
  config_short          = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_monitoring
  azure_extensions        = ["pg_stat_statements", "pgcrypto"]
}
```

### Key vault

An Azure key vault named `${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-kv` containing application secrets.

### Application configuration

```terraform
module "application_configuration" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application_configuration?ref=stable"

  namespace             = var.namespace
  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  is_rails_application = true

  config_variables = {
    HOSTING_ENVIRONMENT = local.environment
  }

  secret_variables = {
    DATABASE_URL = module.postgres.url
    REDIS_URL    = module.redis.url
  }
}
```

### Web application

```terraform
module "web_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=stable"

  name   = "web"
  is_web = true

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
}
```

### Sidekiq application

```terraform
module "worker_application" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/application?ref=stable"

  name   = "worker"
  is_web = false

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image  = var.docker_image
  command       = ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml"]
  probe_command = ["pgrep", "-f", "sidekiq"]
}
```

## Further requirements

### Multiple Key Vaults

Some services will require multiple Key Vaults to store application and infrastructure secrets. It'll require the following changes:

- Two Key Vaults named:
  - `${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-app-kv`
  - `${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-inf-kv`
- Add `secret_key_vault_short = "app"` to the application configuration.
- Add a secrets instance to retrieve infrastructure secrets:
  ```terraform
  module "infrastructure_secrets" {
    source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/secrets?ref=stable"
    
    azure_resource_prefix = var.azure_resource_prefix
    service_short         = var.service_short
    config_short          = var.config_short
    key_vault_short       = "inf"
  }
  ```

### StatusCake

```terraform
terraform {
  required_providers {
    statuscake = {
      source = "StatusCakeDev/statuscake"
    }
  }
}

provider "statuscake" {
  api_token = module.infrastructure_secrets.map.STATUSCAKE-API-TOKEN
}

locals {
  external_url = var.external_hostname != null ? "https://#{var.external_hostname}" : null
}

module "statuscake" {
  count = var.enable_monitoring ? 1 : 0

  source = "git::https://github.com/DFE-Digital/terraform-modules.git//monitoring/statuscake?ref=stable"

  uptime_urls = compact([module.web_application.probe_url, local.external_url])
  ssl_urls    = compact([local.external_url])

  contact_groups = []
}
```
