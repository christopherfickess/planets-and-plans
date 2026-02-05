
output "database_ids" {
  value       = module.postgresql.database_ids
  description = "The IDs of the PostgreSQL databases."
}

output "firewall_rule_ids" {
  value       = module.postgresql.firewall_rule_ids
  description = "The IDs of the PostgreSQL firewall rules."
}

output "server_fqdn" {
  value       = module.postgresql.server_fqdn
  description = "The FQDN of the PostgreSQL server."
}

output "server_id" {
  value       = module.postgresql.server_id
  description = "The ID of the PostgreSQL server."
}

output "administrator_login" {
  value       = module.postgresql.administrator_login
  description = "The administrator login of the PostgreSQL server."
}

output "server_name" {
  value       = module.postgresql.server_name
  description = "The name of the PostgreSQL server."
}

output "vnet_rule_ids" {
  value       = module.postgresql.vnet_rule_ids
  description = "The IDs of the PostgreSQL VNet rules."
}
