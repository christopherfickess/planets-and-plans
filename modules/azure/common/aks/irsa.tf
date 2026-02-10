# modules/azure/common/aks/irsa.tf

resource "azurerm_role_assignment" "aks_users" {
  depends_on = [module.aks.aks_id]

  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azuread_group.aks_users.object_id
}
