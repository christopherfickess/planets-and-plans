resource "azurerm_private_dns_zone" "postgres" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, { Name = var.private_dns_zone_name })
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.unique_name_prefix}-${var.private_dns_zone_virtual_network_link_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = module.avm-res-network-virtualnetwork.resource_id

  registration_enabled = false

  tags = merge(var.tags, { Name = "${var.unique_name_prefix}-${var.private_dns_zone_virtual_network_link_name}" })
}
