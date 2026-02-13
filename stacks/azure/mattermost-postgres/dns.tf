
resource "azurerm_private_dns_a_record" "postgres" {
  name                = var.postgres_dns_name
  zone_name           = data.azurerm_private_dns_zone.postgres.name
  resource_group_name = data.azurerm_private_dns_zone.postgres.resource_group_name
  ttl                 = 300
  records             = [module.postgresql.private_ip]
}
