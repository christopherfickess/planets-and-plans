
# output "mattermost_fqdn" {
#     description = "Fully qualified domain name for Mattermost deployment."
#     value       =  "${azurerm_dns_a_record.mattermost_public[0].name}.${azurerm_dns_a_record.mattermost_public[0].zone_name}"
# }

output "zone_name" {
  value       = azurerm_private_dns_zone.dns.name
  description = "The name of the DNS zone."
}

output "zone_id" {
  value       = azurerm_private_dns_zone.dns.id
  description = "The ID of the DNS zone."
}

output "dns_link_name" {
  value       = azurerm_private_dns_zone_virtual_network_link.dns_link.name
  description = "The name of the DNS link."
}

output "dns_link_id" {
  value       = azurerm_private_dns_zone_virtual_network_link.dns_link.id
  description = "The ID of the DNS link."
}

output "dns_link_resource_group_name" {
  value       = azurerm_private_dns_zone_virtual_network_link.dns_link.resource_group_name
  description = "The resource group of the DNS link."
}

# Public Mattermost DNS (when create_public_mattermost_cname = true)
output "mattermost_public_zone_nameservers" {
  value       = var.create_public_mattermost_cname ? azurerm_dns_zone.mattermost_public[0].name_servers : null
  description = "Nameservers for the public zone. Add as NS records at parent zone to delegate."
}
