
resource "azurerm_role_assignment" "kv_access" {
  scope                = data.azurerm_key_vault.mattermost_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.external_secrets.principal_id
}


resource "azurerm_key_vault_access_policy" "external_secrets" {
  key_vault_id = data.azurerm_key_vault.mattermost_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_user_assigned_identity.external_secrets.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

