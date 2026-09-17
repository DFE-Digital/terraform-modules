terraform {
  required_version = "= 1.14.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.61.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id                 = "5c83eb53-a94f-4778-b258-1f33efe49655"
  resource_provider_registrations = "none"
}
