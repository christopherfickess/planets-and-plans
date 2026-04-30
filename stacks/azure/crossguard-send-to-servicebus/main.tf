# stacks/azure/crossguard-send-to-servicebus/main.tf
#
# Deploys the Azure infrastructure required for CrossGuard Service Bus transport.
# Creates one Service Bus namespace, two queues (inbound + outbound), a scoped SAS rule,
# and one Blob Storage account + container for file attachment transfers.
# No VMs or networking resources — this stack is transport-layer only.

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
  # Required for the azurerm provider to use Azure AD auth for storage data plane
  # operations (blob container creation). Without this the provider falls back to
  # shared key auth and gets a 403 if the caller's identity lacks key access.
  storage_use_azuread = true
  features {}
}
