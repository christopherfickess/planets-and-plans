# stacks/azure/mattermost-vm-crossguard-blob/main.tf

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
  # Required when shared_access_key_enabled = false on storage accounts.
  # Without this the azurerm provider falls back to key-based auth for its own
  # data plane calls (container/queue creation) and gets a 403.
  storage_use_azuread = true
  features {}
}
