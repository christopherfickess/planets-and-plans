terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.59.0"
    }
  }
}

terraform {
  backend "azurerm" {
    location = "eastus"
    encrypt  = true
  }
}

provider "azurerm" {
  features {}
  # features {
  #   # Example setup
  #   resource_group {
  #     prevent_deletion_if_contains_resources = false
  #   }
  # }
}
