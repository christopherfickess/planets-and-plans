


# Private DNS zone
resource "azurerm_private_dns_zone" "nfs_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Link DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "nfs_dns_link" {
  depends_on = [azurerm_private_endpoint.nfs_pe]

  name                  = local.private_dns_zone_vnet_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.nfs_dns.name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet.id
  registration_enabled  = false
}

# Create DNS A record pointing to the private endpoint IP
resource "azurerm_private_dns_a_record" "nfs_a_record" {
  depends_on = [
    azurerm_private_endpoint.nfs_pe,
    azurerm_private_endpoint.nfs_pe
  ]

  name                = local.private_dns_a_record_name
  zone_name           = azurerm_private_dns_zone.nfs_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.nfs_pe.private_service_connection[0].private_ip_address]
}
