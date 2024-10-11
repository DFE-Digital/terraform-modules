terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.6.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = local.gcp_region
}
