
output "database_ids" {
  value       = { for k, v in azurerm_postgresql_flexible_server_database.mattermost_databases : k => v.id }
  description = "The IDs of the PostgreSQL databases."
}

output "firewall_rule_ids" {
  value       = { for k, v in azurerm_postgresql_flexible_server_firewall_rule.rules : k => v.id }
  description = "The IDs of the PostgreSQL firewall rules."
}

output "server_fqdn" {
  value       = azurerm_postgresql_flexible_server.mattermost_postgressql.fqdn
  description = "The FQDN of the PostgreSQL server."
}

output "server_id" {
  value       = azurerm_postgresql_flexible_server.mattermost_postgressql.id
  description = "The ID of the PostgreSQL server."
}

output "administrator_login" {
  value       = azurerm_postgresql_flexible_server.mattermost_postgressql.administrator_login
  description = "The administrator login of the PostgreSQL server."
}

output "server_name" {
  value       = azurerm_postgresql_flexible_server.mattermost_postgressql.name
  description = "The name of the PostgreSQL server."
}

output "host" {
  value       = azurerm_postgresql_flexible_server.mattermost_postgressql.fqdn
  description = "The hostname of the PostgreSQL server."
}

output "port" {
  value       = 5432
  description = "The port of the PostgreSQL server."
}

output "dbname" {
  value       = var.database_names[0]
  description = "The name of the primary PostgreSQL database."
}