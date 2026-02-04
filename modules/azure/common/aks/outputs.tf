output "admin_username" {
  value = module.aks.admin_username
}

output "aks_id" {
  value = module.aks.aks_id
}

output "aks_name" {
  value = module.aks.aks_name
}

output "azure_policy_enabled" {
  value = module.aks.azure_policy_enabled
}

output "azurerm_log_analytics_workspace_id" {
  value = module.aks.azurerm_log_analytics_workspace_id
}

output "azurerm_log_analytics_workspace_name" {
  value = module.aks.azurerm_log_analytics_workspace_name
}

output "ingress_application_gateway_enabled" {
  value = module.aks.ingress_application_gateway_enabled
}

output "key_vault_secrets_provider" {
  value = module.aks.key_vault_secrets_provider
}

output "key_vault_secrets_provider_enabled" {
  value = module.aks.key_vault_secrets_provider_enabled
}

output "location" {
  value = module.aks.location
}

output "network_profile" {
  value = module.aks.network_profile
}

output "username" {
  value = module.aks.username
}

output "aks_admin_group_object_id" {
  value       = data.azuread_group.aks_admins.object_id
  description = "Object ID of the Azure AD group with admin access to AKS"
}

output "aks_user_group_object_id" {
  value       = data.azuread_group.aks_users.object_id
  description = "Object ID of the Azure AD group with user access to AKS"
}
