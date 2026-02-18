

output "key_vault_id" {
  description = "The ID of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.id
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.vault_uri
}

output "key_vault_name" {
  description = "The name of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.name
}

output "key_vault_resource_group" {
  description = "The resource group of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.resource_group_name
}

output "key_vault_location" {
  description = "The location of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.location
}

output "key_vault_tags" {
  description = "The tags of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.tags
}

output "key_vault_access_policies" {
  description = "The access policies of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.access_policy
}

output "key_vault_sku" {
  description = "The SKU of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.sku_name
}

output "key_vault_tenant_id" {
  description = "The tenant ID of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.tenant_id
}

output "key_vault_soft_delete_retention_days" {
  description = "The soft delete retention days of the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.soft_delete_retention_days
}

output "key_vault_purge_protection_enabled" {
  description = "Whether purge protection is enabled for the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.purge_protection_enabled
}

output "key_vault_enable_rbac_authorization" {
  description = "Whether RBAC authorization is enabled for the Azure Key Vault."
  value       = azurerm_key_vault.mattermost_key_vault.enable_rbac_authorization
}

output "key_vault_primary_group_object_id" {
  description = "The object ID of the Azure Key Vault primary group."
  value       = data.azuread_group.primary_group.object_id
}

output "key_vault_primary_group_display_name" {
  description = "The display name of the Azure Key Vault primary group."
  value       = data.azuread_group.primary_group.display_name
}

output "key_vault_primary_group_mail" {
  description = "The mail of the Azure Key Vault primary group."
  value       = data.azuread_group.primary_group.mail
}
