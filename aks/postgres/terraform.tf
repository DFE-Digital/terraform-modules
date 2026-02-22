terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3, <4"
    }
    azurermv4 = {
      source  = "hashicorp/azurerm"
      version = ">4"
      configuration_aliases = [azurermv4.main]
    }
  }
}

# Modern provider configuration
provider "azurerm" {
}

# Legacy provider for resources requiring older version
provider "azurermv4" {
  alias  = "main"
}
