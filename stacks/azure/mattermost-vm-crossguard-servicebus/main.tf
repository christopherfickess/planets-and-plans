# stacks/azure/mattermost-vm-crossguard-servicebus/main.tf

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
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
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
