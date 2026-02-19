resource "tls_private_key" "jumpbox" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "azurerm_key_vault" "jumpbox" {
  name                       = local.keyvault_name
  location                   = data.azurerm_resource_group.mattermost_location.location
  resource_group_name        = data.azurerm_resource_group.mattermost_location.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  enable_rbac_authorization  = true

  tags = merge(local.tags, { name = local.keyvault_name })
}

resource "azurerm_role_assignment" "kv_secrets_officer" {
  depends_on           = [azurerm_key_vault.jumpbox]
  scope                = azurerm_key_vault.jumpbox.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_azure_pde_secrets_user" {
  depends_on           = [azurerm_key_vault.jumpbox]
  scope                = azurerm_key_vault.jumpbox.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_group.azure_pde.object_id
}

resource "azurerm_key_vault_secret" "jumpbox_private_key" {
  depends_on   = [azurerm_role_assignment.kv_secrets_officer]
  name         = local.keyvault_private_key_secret_name
  value        = tls_private_key.jumpbox.private_key_pem
  key_vault_id = azurerm_key_vault.jumpbox.id
  content_type = "ssh-private-key"
}

resource "azurerm_key_vault_secret" "jumpbox_public_key" {
  depends_on   = [azurerm_role_assignment.kv_secrets_officer]
  name         = local.keyvault_pub_key_secret_name
  value        = tls_private_key.jumpbox.public_key_openssh
  key_vault_id = azurerm_key_vault.jumpbox.id
  content_type = "ssh-public-key"
}

