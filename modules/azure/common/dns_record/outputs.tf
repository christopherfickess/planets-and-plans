
# output "mattermost_fqdn" {
#     description = "Fully qualified domain name for Mattermost deployment."
#     value       =  "${azurerm_dns_a_record.mattermost_public[0].name}.${azurerm_dns_a_record.mattermost_public[0].zone_name}"
# }