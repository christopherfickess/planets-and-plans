# stacks/azure/mattermost-bastion/main.tf

terraform {
  backend "azurerm" {
    location = "eastus"
    encrypt  = true
  }
}

provider "azurerm" {
  features {}
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
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
