# stacks/azure/mattermost-azk/data.tf


data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
# data "azurerm_countries" "all" {}
# data "azurerm_locations" "available" {
# subscription_id = data.azurerm_subscription.current.subscription_id
# }


data "azurerm_resource_group" "mattermost_location" {
  name = var.resource_group_name
}

resource "time_static" "deployment_date" {
  triggers = {
    always_run = "true" # optional, to force creation only once
  }
}

output "current_time" {
  value = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
}

data "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "db" {
  name                 = var.db_subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Key vault secrets for Postgres credentials
data "azurerm_key_vault_secret" "postgres_internal_user" {
  depends_on = [azurerm_key_vault_secret.postgres_internal_user]

  name         = var.keyvault_name_internal_user
  key_vault_id = data.azurerm_key_vault.mattermost_key_vault.id
}

data "azurerm_key_vault_secret" "postgres_internal_password" {
  depends_on = [azurerm_key_vault_secret.postgres_internal_password]

  name         = var.keyvault_name_internal_password
  key_vault_id = data.azurerm_key_vault.mattermost_key_vault.id
}

# Service account for External Secrets (if using workload identity)
# Must match AKS service_accounts uami_name: "${base_identifier}-external-secrets-identity"
data "azurerm_user_assigned_identity" "external_secrets" {
  name                = local.external_secrets_uami_name
  resource_group_name = var.resource_group_name
}

