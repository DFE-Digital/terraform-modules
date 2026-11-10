variable "environment" {
  type        = string
  description = "Name of the deployed environment in AKS"
}

variable "azure_resource_prefix" {
  type        = string
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}

variable "config" {
  type        = string
  description = "Long name of the environment configuration, e.g. development, staging, production..."
}

variable "config_short" {
  type        = string
  description = "Short name of the environment configuration, e.g. dv, st, pd..."
}

variable "service_name" {
  type        = string
  description = "Full name of the service. Lowercase and hyphen separated"
}

variable "service_short" {
  type        = string
  description = "Short name to identify the service. Up to 6 characters."
}

variable "location" {
  default = "UK South"
}

variable "enable_postgres" {
  default = false
}

variable "enable_sql" {
  default = false
}

variable "enable_redis" {
  default = false
}

variable "enable_apps" {
  default = false
}

variable "enable_storage" {
  default = false
}

variable "vnet_address" {
  default = ["10.0.0.0/12"]
}

variable "postgres_subnet" {
  default = ["10.2.0.0/18"]
}

variable "sql_subnet" {
  default = ["10.2.192.0/18"]
}

variable "redis_subnet" {
  default = ["10.2.64.0/18"]
}

variable "apps_subnet" {
  description = "The subnet address range for the apps subnet. This is used for the web app and function app subnets and includes vnet integration. See https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration#windows-worker-ip-address-overlap for more information and ranges to avoid."  
  default = ["10.3.0.0/18"]
}

variable "storage_subnet" {
  default = ["10.2.128.0/18"]
}

variable "enable_generic_private_endpoints" {
  default = false
}

variable "generic_private_endpoints_subnet" {
  description = "The subnet address range for the generic private endpoints subnet. This is used for private endpoints that are not in the other subnets, e.g. Key Vault, App Service, etc."    
  default = []
}

variable "private_dns_zones" {
  description = "The name of the private DNS zone to create. This is used for private endpoints that are not in the other subnets, e.g. Key Vault, App Service, etc."
  default = ["privatelink.blob.core.windows.net"]
}

# variable "create_default_vault_private_endpoints" {
#   description = "Whether to create a private endpoint for the default app and inf Key Vaults."
#   default = true
# }