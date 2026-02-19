# -----------------------------------------------------------------------------
# Azure PDE - Contributor access to all resources in the resource group
# -----------------------------------------------------------------------------
# Grants Azure PDE group Contributor role at RG scope, covering:
# VNet, subnets, Key Vault, Load Balancer, DNS, and any other resources in the RG.
# Other stacks (AKS, Postgres, NFS, Bastion) deploy to the same RG, so this
# provides Azure PDE access to manage all Mattermost infrastructure.
# -----------------------------------------------------------------------------

data "azuread_group" "azure_pde" {
  display_name = var.azure_primary_group_display_name
}

resource "azurerm_role_assignment" "azure_pde_contributor" {
  scope                = data.azurerm_resource_group.mattermost_location.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.azure_pde.object_id
}
