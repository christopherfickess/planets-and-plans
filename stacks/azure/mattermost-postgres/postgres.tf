

module "mattermost_postgres" {
  depends_on = [azurerm_key_vault_secret.pg, azurerm_key_vault_secret.postgres_user]

  source         = "../../../modules/azure/common/postgres"
  module_version = "11.0.0"
  server_version = "11"

  unique_name_prefix     = var.unique_name_prefix
  resource_group_name    = var.resource_group_name
  location               = var.location
  server_name            = local.server_name
  administrator_login    = azurerm_key_vault_secret.postgres_user.value
  administrator_password = azurerm_key_vault_secret.pg.value
  database_names         = local.database_names

  firewall_rules = [
    # Only if public network access is enabled and you want to allow specific IP ranges (not in same VNet). 
    # Example:
    # {
    #   name     = "allow-office-ip"
    #   start_ip = data.azurerm_subnet.aks.address_prefixes[0]
    #   end_ip   = data.azurerm_subnet.aks.address_prefixes[0]
    # }
  ]

  vnet_rules = [
    {
      name      = "allow-db-subnet"
      subnet_id = data.azurerm_subnet.db.id
    }
  ]

  environment   = var.environment
  email_contact = var.email_contact

  # Storage Size in MB
  storage_mb = var.storage_mb
  sku_name   = var.sku_name

  tags = merge(
    local.tags,
    {
      Project = "Mattermost Deployment"
    }
  )
}
