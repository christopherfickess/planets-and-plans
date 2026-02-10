
data "azurerm_key_vault" "existing" {
  name                = local.keyvault_name
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
}

resource "azurerm_key_vault" "mattermost_key_vault" {
  count = length(data.azurerm_key_vault.existing.id) > 0 ? 0 : 1

  name                       = local.keyvault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = false
  # enable_rbac_authorization = true
}

locals {
  keyvault_id = length(azurerm_key_vault.mattermost_key_vault) > 0 ? azurerm_key_vault.mattermost_key_vault[0].id : data.azurerm_key_vault.existing.id
}

resource "random_password" "postgres_password" {
  length           = 16
  override_special = "_-!%&*" # Only safe special characters for db passwords
  upper            = true
  lower            = true
  numeric          = true
  special          = true
}

resource "azurerm_key_vault_secret" "pg" {
  name         = var.keyvault_name_password
  value        = random_password.postgres_password.result
  key_vault_id = local.keyvault_id
}

# Second secret: Postgres admin username
resource "azurerm_key_vault_secret" "postgres_user" {
  name         = var.keyvault_name_user
  value        = var.db_username
  key_vault_id = local.keyvault_id
}
