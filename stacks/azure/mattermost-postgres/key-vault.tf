
# resource "azurerm_resource_group" "example" {
#   name     = "rg-example"
#   location = "eastus"
# }

resource "azurerm_key_vault" "mattermost_key_vault" {
  name                      = local.keyvault_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  purge_protection_enabled  = false
  enable_rbac_authorization = true
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
  depends_on = [azurerm_key_vault.mattermost_key_vault]

  name         = "postgres-password"
  value        = random_password.postgres_password.result
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id
}

# Second secret: Postgres admin username
resource "azurerm_key_vault_secret" "postgres_user" {
  name         = "postgres-username"
  value        = "mmcloudadmin"
  key_vault_id = azurerm_key_vault.mattermost_key_vault.id
}
