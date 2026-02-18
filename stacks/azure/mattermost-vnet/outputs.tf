

output "vnet_variables" {
  value = {
    address_spaces = module.mattermost_vnet.address_spaces
    vnet_name      = module.mattermost_vnet.vnet_name
    vnet_id        = module.mattermost_vnet.vnet_id
    peerings       = module.mattermost_vnet.peerings
    resource       = module.mattermost_vnet.resource
    subnets        = module.mattermost_vnet.subnets
    # aks_subnet_id    = module.mattermost_vnet.aks_subnet_id
    nat_gateway_id   = module.mattermost_vnet.nat_gateway_id
    nat_public_ip_id = module.mattermost_vnet.nat_public_ip_id
  }
}

output "dns_record_variables" {
  value = {
    zone_name     = module.dns_record.zone_name
    zone_id       = module.dns_record.zone_id
    dns_link_name = module.dns_record.dns_link_name
    dns_link_id   = module.dns_record.dns_link_id
  }
}

output "view_dns_record" {
  value = <<-EOT
  az network private-dns zone list --resource-group ${var.resource_group_name}
  az network private-dns zone show --name ${var.mattermost_domain} --resource-group ${var.resource_group_name}
  az network private-dns record-set a list --zone-name ${var.mattermost_domain} --resource-group ${var.resource_group_name}
  az network private-dns zone-virtual-network-link list --resource-group ${var.resource_group_name}
  az network private-dns zone-virtual-network-link show --name ${module.dns_record.dns_link_name} --zone-name ${var.mattermost_domain} --resource-group ${var.resource_group_name}
  EOT
}
