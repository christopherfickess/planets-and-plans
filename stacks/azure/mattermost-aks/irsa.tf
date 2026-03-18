
data "azuread_group" "aks_pde_admins" {
  display_name = var.azure_primary_group_display_name
}

resource "azurerm_role_assignment" "aks_pde_admins" {
  depends_on = [module.mattermost_aks]

  scope                = module.mattermost_aks.aks_id
  role_definition_name = "Azure Kubernetes Service RBAC Admin" # Built-in role
  principal_id         = data.azuread_group.aks_pde_admins.object_id
}

# resource "azurerm_role_assignment" "aks_admin" {
#   depends_on = [module.mattermost_aks]

#   scope                = module.mattermost_aks.aks_id
#   role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
#   principal_id         = data.azuread_group.pde_group.object_id
# }


# resource "azuread_group" "azure_admin_cluster_subscription" {
#   display_name     = "${var.unique_name_prefix}-cluster-admin"
#   description      = "Azure AD group for cluster admin"
#   security_enabled = true
#   visibility       = "Private"
#   mail_enabled     = false
#   mail_nickname    = "${var.unique_name_prefix}-cluster-admin"
# }
