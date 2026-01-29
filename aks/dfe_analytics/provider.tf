terraform {
  required_version = ">=1.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3, <5"
    }
  }
}
