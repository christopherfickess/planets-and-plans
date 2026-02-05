# stacks/azure/mattermost-azk/main.tf

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

terraform {
  required_version = ">= 1.14.0"


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.16.0, < 5.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.8"
    # }
  }
}


# Used to point to the resource group for storing Terraform state
# resource "azurerm_resource_group" "mattermost_location" {
#   name     = var.resource_group_name
#   location = var.location
#   tags     = local.tags
# }
