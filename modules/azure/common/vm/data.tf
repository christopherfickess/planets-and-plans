data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

# Required for Key Vault tenant_id and the Secrets Officer role assignment.
data "azurerm_client_config" "current" {}
