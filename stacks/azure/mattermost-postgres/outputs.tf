

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
