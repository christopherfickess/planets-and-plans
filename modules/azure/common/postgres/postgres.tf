
module "postgresql" {
  source = "Azure/postgresql/azurerm"

  resource_group_name = var.resource_group_name
  location            = var.location

  server_name                   = var.server_name
  sku_name                      = "GP_Gen5_2"
  storage_mb                    = 5120
  auto_grow_enabled             = false
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  server_version                = var.server_version
  ssl_enforcement_enabled       = true
  public_network_access_enabled = true
  db_names                      = var.database_names
  db_charset                    = "UTF8"
  db_collation                  = "English_United States.1252"

  firewall_rule_prefix = "firewall-"
  firewall_rules       = var.firewall_rules

  vnet_rule_name_prefix = "postgresql-vnet-rule-"
  vnet_rules            = var.vnet_rules

  tags = {
    Environment         = var.environment,
    Owner               = var.email_contact,
    Location            = var.location,
    Module              = "postgresql",
    Version             = var.module_version,
    Resource_Group_Name = var.resource_group_name
  }

  postgresql_configurations = {
    backslash_quote = "on",
  }

  depends_on = [azurerm_resource_group.example]
}
