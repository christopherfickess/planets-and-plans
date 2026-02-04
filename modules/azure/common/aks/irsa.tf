# modules/azure/common/aks/irsa.tf

resource "azurerm_role_assignment" "aks_users" {
  depends_on = [module.aks.aks_id]

  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azuread_group.aks_users.object_id
}

# resource "azuread_group" "aks_admins" {
#   display_name     = var.admin_group_display_name
#   security_enabled = true
# }

# resource "azuread_group" "aks_users" {
#   display_name     = var.user_group_display_name
#   security_enabled = true
# }


## Sample IRSA Role Assignment
# resource "azurerm_user_assigned_identity" "app" {
#   name                = "my-app-identity"
#   location            = var.location
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_federated_identity_credential" "app" {
#   name                = "my-app-federation"
#   resource_group_name = var.resource_group_name
#   parent_id           = azurerm_user_assigned_identity.app.id

#   issuer   = azurerm_kubernetes_cluster.aks.oidc_issuer_url
#   subject  = "system:serviceaccount:default:my-service-account"
#   audience = ["api://AzureADTokenExchange"]
# }

# Custom Role Definition Example
# resource "azurerm_role_definition" "app_custom_blob_reader" {
#   name        = "CustomBlobReader"
#   scope       = data.azurerm_subscription.current.id
#   description = "Read-only blob access"

#   permissions {
#     actions = [
#       "Microsoft.Storage/storageAccounts/blobServices/containers/read",
#       "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"
#     ]
#     not_actions = []
#   }

#   assignable_scopes = [
#     data.azurerm_subscription.current.id
#   ]
# }
