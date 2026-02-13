

output "postgres_variables" {
  value = {
    database_ids        = module.mattermost_postgres.database_ids
    firewall_rule_ids   = module.mattermost_postgres.firewall_rule_ids
    server_fqdn         = module.mattermost_postgres.server_fqdn
    server_id           = module.mattermost_postgres.server_id
    administrator_login = module.mattermost_postgres.administrator_login
    server_name         = module.mattermost_postgres.server_name
    vnet_rule_ids       = module.mattermost_postgres.vnet_rule_ids
  }
  sensitive = true
}

# output "postgresql_role_mm_cloud" {
#   value       = azurerm_key_vault_secret.postgres_internal_user.value
#   description = "The name of the PostgreSQL role created for Mattermost internal use."
#   sensitive   = true
# }

# output "postgresql_role_mm_cloud_password" {
#   value       = azurerm_key_vault_secret.postgres_internal_password.value
#   description = "The password of the PostgreSQL role created for Mattermost internal use."
#   sensitive   = true
# }
