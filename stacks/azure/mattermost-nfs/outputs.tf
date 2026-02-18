
output "current_time" {
  value = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
}

output "nfs" {
  value = {
    nfs_id             = module.nfs.nfs_id
    nfs_name           = module.nfs.nfs_name
    nfs_share_id       = module.nfs.nfs_share_id
    nfs_share_name     = module.nfs.nfs_share_name
    nfs_share_quota_gb = module.nfs.nfs_share_quota_gb
  }
}

output "dns_record" {
  value = {
    zone_name          = module.dns_record.zone_name
    zone_id            = module.dns_record.zone_id
    dns_link_name      = module.dns_record.dns_link_name
    dns_link_id        = module.dns_record.dns_link_id
    a_record_id        = azurerm_private_dns_a_record.nfs_a_record.id
    a_record_name      = azurerm_private_dns_a_record.nfs_a_record.name
    a_record_zone_name = azurerm_private_dns_a_record.nfs_a_record.zone_name
  }
}

output "connect_to_nfs" {
  value = <<-EOT

  Connect to the DNS zone:
  az network private-dns zone list --resource-group ${var.resource_group_name}
  az network private-dns zone show --name ${var.private_dns_zone_name} --resource-group ${var.resource_group_name}
  az network private-dns record-set a list --zone-name ${var.private_dns_zone_name} --resource-group ${var.resource_group_name}
  az network private-dns record-set a show --name ${local.private_dns_a_record_name} --zone-name ${var.private_dns_zone_name} --resource-group ${var.resource_group_name}

  Connect to the DNS link:
  az network private-dns zone-virtual-network-link list --resource-group ${var.resource_group_name}
  az network private-dns zone-virtual-network-link show --name ${module.dns_record.dns_link_name} --zone-name ${var.private_dns_zone_name} --resource-group ${var.resource_group_name}
  az network private-dns zone-virtual-network-link list --resource-group "<resource_group_name>"
  az network private-dns zone-virtual-network-link show --name ${module.dns_record.dns_link_name} --zone-name ${var.private_dns_zone_name} --resource-group ${var.resource_group_name}

  Connect to the NFS share:
  az storage share list --account-name ${module.nfs.nfs_name}
  az storage share show --account-name ${module.nfs.nfs_name} --name ${module.nfs.nfs_share_name}
  az storage share list --account-name ${module.nfs.nfs_name} --name ${module.nfs.nfs_share_name}
  az storage share show --account-name ${module.nfs.nfs_name} --name ${module.nfs.nfs_share_name}

  Connect to the NFS private endpoint:
  az network private-endpoint list --resource-group ${var.resource_group_name}
  az network private-endpoint show --name ${module.nfs.nfs_pe_name} --resource-group ${var.resource_group_name}
  az network private-endpoint list --resource-group ${var.resource_group_name} --name ${module.nfs.nfs_pe_name} --output table

  Connect to the NFS private endpoint IP:
  az network private-endpoint list --resource-group ${var.resource_group_name}
  az network private-endpoint show --name ${module.nfs.nfs_pe_name} --resource-group ${var.resource_group_name}
  az network private-endpoint list --resource-group ${var.resource_group_name} --name ${module.nfs.nfs_pe_name} --output table


  az network private-endpoint show --name ${module.nfs.nfs_pe_name} --resource-group ${var.resource_group_name}
  az network private-endpoint list --resource-group ${var.resource_group_name} --name ${module.nfs.nfs_pe_name} --output table
  EOT
}
