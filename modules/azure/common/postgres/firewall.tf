
resource "azurerm_postgresql_flexible_server_firewall_rule" "rules" {
  for_each = {
    for rule in var.firewall_rules :
    rule.name => rule
  }

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.mattermost_postgressql.id

  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}
