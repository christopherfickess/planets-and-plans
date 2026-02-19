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
  required_version = ">= 1.13.0"


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.16.0, < 5.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.14"
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
