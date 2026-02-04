

# Output AKS Variables
output "aks_variables" {
  value = {
    aks_id                               = module.mattermost_aks.aks_id
    admin_username                       = module.mattermost_aks.admin_username
    aks_name                             = module.mattermost_aks.aks_name
    azure_policy_enabled                 = module.mattermost_aks.azure_policy_enabled
    azurerm_log_analytics_workspace_id   = module.mattermost_aks.azurerm_log_analytics_workspace_id
    azurerm_log_analytics_workspace_name = module.mattermost_aks.azurerm_log_analytics_workspace_name
    ingress_application_gateway_enabled  = module.mattermost_aks.ingress_application_gateway_enabled
    key_vault_secrets_provider           = module.mattermost_aks.key_vault_secrets_provider
    key_vault_secrets_provider_enabled   = module.mattermost_aks.key_vault_secrets_provider_enabled
    location                             = module.mattermost_aks.location
    network_profile                      = module.mattermost_aks.network_profile
    username                             = module.mattermost_aks.username
  }
  sensitive = true
}

output "aks_admin_group_object_id" {
  value       = module.mattermost_aks.aks_admin_group_object_id
  description = "Object ID of the Azure AD group with admin access to AKS"
}

output "aks_user_group_object_id" {
  value       = module.mattermost_aks.aks_user_group_object_id
  description = "Object ID of the Azure AD group with user access to AKS"
}
