# stacks/azure/crossguard-send-to-blob/main.tf
#
# Deploys the Azure storage infrastructure required for CrossGuard blob transport.
# Creates one storage account and one blob container.
# No VMs or networking resources are created — this stack is transport-only.

terraform {
  backend "azurerm" {
    location = "eastus2"
    encrypt  = true
  }

  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.16.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = true
  features {}
}
