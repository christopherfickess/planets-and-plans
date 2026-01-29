resource "azuread_group" "aks_admins" {
  display_name     = var.admin_group_display_name
  security_enabled = true
}

resource "azuread_group" "aks_users" {
  display_name     = var.admin_group_display_name
  security_enabled = true
}

resource "azurerm_role_assignment" "aks_admins" {
  depends_on = [module.aks.aks_id]

  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = var.admin_group_display_name
}

# resource "azurerm_role_assignment" "acr_admin" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPush"
#   principal_id         = var.admin_group_display_name
# }

# resource "azurerm_role_assignment" "aks_network" {
#   scope                = azurerm_subnet.aks.id
#   role_definition_name = "Network Contributor"
#   principal_id         = var.admin_group_display_name
# }

# resource "azurerm_role_assignment" "blob_admin" {
#   scope                = azurerm_storage_account.data.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = var.admin_group_display_name
# }

resource "azurerm_role_assignment" "aks_users" {
  depends_on = [module.aks.aks_id]

  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.user_group_display_name
}
