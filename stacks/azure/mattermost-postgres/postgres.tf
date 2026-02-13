

module "mattermost_postgres" {
  depends_on = [azurerm_key_vault_secret.postgres_admin_password, azurerm_key_vault_secret.postgres_admin_user]

  source         = "../../../modules/azure/common/postgres"
  module_version = "11.0.0"
  server_version = "11"

  unique_name_prefix     = var.unique_name_prefix
  resource_group_name    = var.resource_group_name
  location               = var.location
  server_name            = local.server_name
  administrator_login    = azurerm_key_vault_secret.postgres_admin_user.value
  administrator_password = azurerm_key_vault_secret.postgres_admin_password.value
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

  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  delegated_subnet_id           = data.azurerm_subnet.db.id
  private_dns_zone_id           = module.mattermost_vnet.postgres_private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled
  db_collation                  = var.db_collation
  db_charset                    = var.db_charset

  tags = merge(
    local.tags,
    {
      Project = "Mattermost Deployment"
    }
  )
}
