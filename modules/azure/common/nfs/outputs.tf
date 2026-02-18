output "nfs_id" {
  value       = azurerm_storage_account.nfs_sa.id
  description = "The ID of the Azure Storage Account."
}

output "nfs_name" {
  value       = azurerm_storage_account.nfs_sa.name
  description = "The name of the Azure Storage Account."
}

output "nfs_share_id" {
  value       = azurerm_storage_share.nfs_share.id
  description = "The ID of the Azure Storage Share."
}

output "nfs_share_name" {
  value       = azurerm_storage_share.nfs_share.name
  description = "The name of the Azure Storage Share."
}

output "nfs_share_quota_gb" {
  value       = azurerm_storage_share.nfs_share.quota
  description = "The quota of the Azure Storage Share in GB."
}

output "nfs_pe_id" {
  value       = azurerm_private_endpoint.nfs_pe.id
  description = "The ID of the Azure Private Endpoint."
}

output "nfs_pe_name" {
  value       = azurerm_private_endpoint.nfs_pe.name
  description = "The name of the Azure Private Endpoint."
}

output "nfs_pe_private_ip_address" {
  value       = azurerm_private_endpoint.nfs_pe.private_service_connection[0].private_ip_address
  description = "The private IP address of the Azure Private Endpoint."
}

output "nfs_pe_subnet_id" {
  value       = azurerm_private_endpoint.nfs_pe.subnet_id
  description = "The ID of the subnet of the Azure Private Endpoint."
}

output "nfs_pe_subnet_name" {
  value       = data.azurerm_subnet.aks_subnet.name
  description = "The name of the subnet of the Azure Private Endpoint."
}

output "nfs_pe_resource_group_name" {
  value       = data.azurerm_subnet.aks_subnet.resource_group_name
  description = "The resource group of the Azure Private Endpoint."
}
