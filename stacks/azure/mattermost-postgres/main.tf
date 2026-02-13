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
  required_version = ">= 1.13.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
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

provider "postgresql" {
  alias = "mattermost"

  port     = 5432
  database = "postgres"
  host     = module.mattermost_postgres.server_fqdn
  username = azurerm_key_vault_secret.postgres_admin_user.value
  password = azurerm_key_vault_secret.postgres_admin_password.value
  sslmode  = "require"
}
