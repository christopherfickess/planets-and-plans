

resource "azurerm_key_vault" "mattermost_key_vault" {
  name                       = "${var.unique_name_prefix}-${var.keyvault_name}"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = var.purge_protection_enabled
  enable_rbac_authorization  = false

  tags = merge(var.tags, { Name = "${var.unique_name_prefix}-${var.keyvault_name}" })
}


resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
  ]
}

resource "azurerm_key_vault_access_policy" "primary_group_admin" {
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_group.primary_group.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Update",
    "Import",
    "Delete",
    "Backup",
    "Restore",
    "Recover",
    "Purge"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Backup",
    "Restore",
    "Recover",
    "Purge"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Delete",
    "Create",
    "Import",
    "Update",
    "ManageContacts",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers",
    "ManageIssuers",
    "Recover",
    "Purge"
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update"
  ]
}
