resource "azurerm_key_vault" "mattermost_key_vault" {
  name                       = local.keyvault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = false
  enable_rbac_authorization  = false

  tags = merge(local.tags, { Project = "Mattermost Deployment" })
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

data "azuread_group" "pde_group" {
  display_name = var.azure_pde_admin_group_display_name
}

resource "azurerm_key_vault_access_policy" "pde_group_admin" {
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_group.pde_group.object_id

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

# resource "azurerm_role_assignment" "terraform_sp_keyvault" {
#   scope                = azurerm_key_vault.mattermost_key_vault.id
#   role_definition_name = "Key Vault Contributor"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

resource "random_password" "postgres_admin_password" {
  length           = 16
  override_special = "_-!%&*" # Only safe special characters for db passwords
  upper            = true
  lower            = true
  numeric          = true
  special          = true
}

resource "azurerm_key_vault_secret" "postgres_admin_password" {
  depends_on = [azurerm_key_vault_access_policy.terraform_sp]


  name         = var.keyvault_name_admin_password
  value        = random_password.postgres_admin_password.result
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(local.tags, { Project = "Mattermost Postgres Admin Password" })
}

# Second secret: Postgres admin username
resource "azurerm_key_vault_secret" "postgres_admin_user" {
  depends_on = [azurerm_key_vault_access_policy.terraform_sp]


  name         = var.keyvault_name_admin_user
  value        = var.db_admin_username
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(local.tags, { Project = "Mattermost Postgres Admin User" })
}

# Mattermost internal DB user and password secrets (optional, for better security practices)

resource "random_password" "postgres_internal_password" {

  length           = 16
  override_special = "_-!%&*" # Only safe special characters for db passwords
  upper            = true
  lower            = true
  numeric          = true
  special          = true
}

resource "azurerm_key_vault_secret" "postgres_internal_password" {
  depends_on = [azurerm_key_vault_access_policy.terraform_sp]

  name         = var.keyvault_name_internal_password
  value        = random_password.postgres_internal_password.result
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(local.tags, { Project = "Mattermost Postgres Internal Password" })
}

resource "azurerm_key_vault_secret" "postgres_internal_user" {
  depends_on = [azurerm_key_vault_access_policy.terraform_sp]

  name         = var.keyvault_name_internal_user
  value        = var.db_internal_username
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(local.tags, { Project = "Mattermost Postgres Internal User" })
}


# List secrets in the key vault (for verification, not typically used in production code)
# az keyvault secret list \
#   --vault-name mattermost-dev-chris-pgs \
#   --query "[].{name:name,id:id}" \
#   -o table
# az keyvault secret show --vault-name mattermost-dev-chris-pgs --name postgres-admin-password --query value -o tsv
