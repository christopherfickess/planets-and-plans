# stacks/azure/crossguard-send-to-queue/main.tf
#
# Deploys the Azure storage infrastructure required for CrossGuard queue transport.
# Creates one storage account, two queues (inbound + outbound), and one blob container.
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
