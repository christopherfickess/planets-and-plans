
# Private DNS zone
resource "azurerm_private_dns_zone" "dns" {
  name                = var.mattermost_domain
  resource_group_name = var.resource_group_name
  tags               = merge(var.tags, { "Name" = var.mattermost_domain })
}


# Link DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  depends_on = [azurerm_private_dns_zone.dns]

  name                  = var.private_dns_zone_vnet_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet.id
  registration_enabled  = false

  tags = merge(var.tags, { "Name" = var.private_dns_zone_vnet_link_name })
}
