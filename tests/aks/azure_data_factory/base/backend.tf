terraform {
  backend "azurerm" {
    resource_group_name  = "s189d01-eprdat-ts-rg"
    storage_account_name = "s189d01eprdatdevelopment"
    container_name       = "tfstate"
    key                  = "base-terraform.tfstate"
  }
}
