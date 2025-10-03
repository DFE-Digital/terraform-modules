terraform {
  required_providers {
    airbyte = {
      source = "airbytehq/airbyte"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.6.0"
    }
  }
}
