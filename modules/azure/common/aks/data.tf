

data "azuread_group" "aks_admins" {
  display_name = var.admin_group_display_name
}
data "azuread_group" "aks_users" {
  display_name = var.user_group_display_name
}

# data "azuread_group" "aks_pde_admins" {
#   display_name = var.azure_pde_admin_group_display_name
# }


# resource "azurerm_role_assignment" "aks_pde_admins" {
#   depends_on = [module.aks]

#   scope                = module.aks.aks_id
#   role_definition_name = "Azure Kubernetes Service RBAC Admin" # Built-in role
#   principal_id         = data.azuread_group.aks_pde_admins.object_id
# }
