resource "azurerm_postgresql_flexible_server" "mattermost_postgressql" {
  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  version    = var.server_version
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each = toset(var.database_names)

  name      = each.value
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = var.db_collation
  charset   = var.db_charset
}
