terraform {
  required_version = ">=1.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.6.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = local.gcp_region
}
