
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
  }
}

terraform {
  backend "azurerm" {
    location = "eastus"
    encrypt  = true
  }
}

locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "${var.environment}-mattermost-${local.date}"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
  }
}

# Used to point to the resource group for storing Terraform state
resource "azurerm_resource_group" "mattermost_location" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}
