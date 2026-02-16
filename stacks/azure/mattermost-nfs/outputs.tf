
output "current_time" {
  value = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
}

output "vnet" {
  value = {
    vnet_name       = data.azurerm_virtual_network.aks_vnet.name
    vnet_id         = data.azurerm_virtual_network.aks_vnet.id
    aks_subnet_name = data.azurerm_subnet.aks_subnet.name
    aks_subnet_id   = data.azurerm_subnet.aks_subnet.id
  }
}

output "dns_zone" {
  value = {
    dns_zone_name = azurerm_private_dns_zone.nfs_dns.name
    dns_zone_id   = azurerm_private_dns_zone.nfs_dns.id
  }
}

output "dns_a_record" {
  value = {
    dns_a_record_name = azurerm_private_dns_a_record.nfs_a_record.name
    dns_a_record_fqdn = azurerm_private_dns_a_record.nfs_a_record.fqdn
    dns_a_record_ip   = azurerm_private_dns_a_record.nfs_a_record.records
  }
}


output "azurerm_private_endpoint" {
  value = {
    name               = azurerm_private_endpoint.nfs_pe.name
    private_ip_address = azurerm_private_endpoint.nfs_pe.private_service_connection[0].private_ip_address
    resource_id        = azurerm_private_endpoint.nfs_pe.id
    subnet_id          = azurerm_private_endpoint.nfs_pe.subnet_id
  }
}

output "storage_account" {
  value = {
    name        = azurerm_storage_account.nfs_sa.name
    resource_id = azurerm_storage_account.nfs_sa.id
  }
}

output "storage_share" {
  value = {
    name        = azurerm_storage_share.nfs_share.name
    resource_id = azurerm_storage_share.nfs_share.id
  }
}

output "dns_zone_virtual_network_link" {
  value = {
    name                  = azurerm_private_dns_zone_virtual_network_link.nfs_dns_link.name
    resource_id           = azurerm_private_dns_zone_virtual_network_link.nfs_dns_link.id
    private_dns_zone_name = azurerm_private_dns_zone_virtual_network_link.nfs_dns_link.private_dns_zone_name
    virtual_network_id    = azurerm_private_dns_zone_virtual_network_link.nfs_dns_link.virtual_network_id
  }
}
