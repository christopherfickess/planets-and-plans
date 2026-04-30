# stacks/azure/mattermost-vm-crossguard-servicebus/outputs.tf

output "vm_a_public_ip" {
  value       = module.vm_a.vm_public_ip
  description = "Public IP of Mattermost VM A."
}

output "vm_b_public_ip" {
  value       = module.vm_b.vm_public_ip
  description = "Public IP of Mattermost VM B."
}

output "vm_a_fqdn" {
  value       = module.vm_a.vm_fqdn
  description = "Azure DNS FQDN for VM A."
}

output "vm_b_fqdn" {
  value       = module.vm_b.vm_fqdn
  description = "Azure DNS FQDN for VM B."
}

output "vm_a_key_vault_name" {
  value       = module.vm_a.key_vault_name
  description = "Key Vault holding VM A's SSH key pair."
}

output "vm_b_key_vault_name" {
  value       = module.vm_b.key_vault_name
  description = "Key Vault holding VM B's SSH key pair."
}

output "vm_a_connection_instructions" {
  value       = module.vm_a.connection_instructions
  description = "SSH connection steps for VM A."
}

output "vm_b_connection_instructions" {
  value       = module.vm_b.connection_instructions
  description = "SSH connection steps for VM B."
}

output "namespace_name" {
  value       = module.service_bus.namespace_name
  description = "CrossGuard Service Bus namespace name."
}

output "inbound_queue_name" {
  value       = module.service_bus.inbound_queue_name
  description = "Inbound queue name. Set as queue_name on the receiving connection in the CrossGuard plugin config."
}

output "outbound_queue_name" {
  value       = module.service_bus.outbound_queue_name
  description = "Outbound queue name. Set as queue_name on the sending connection in the CrossGuard plugin config."
}

output "connection_string" {
  value       = module.service_bus.connection_string
  description = "Primary SAS connection string (Send+Listen). Set as connection_string in the CrossGuard azure_servicebus config block."
  sensitive   = true
}

output "secondary_connection_string" {
  value       = module.service_bus.secondary_connection_string
  description = "Secondary SAS connection string. Use for zero-downtime key rotation."
  sensitive   = true
}

output "blob_storage_account_name" {
  value       = module.blob_storage.storage_account_name
  description = "Blob storage account name. Set as blob_account_name in the CrossGuard azure_servicebus config block."
}

output "blob_endpoint" {
  value       = module.blob_storage.blob_endpoint
  description = "Blob endpoint URL. Set as blob_service_url in the CrossGuard azure_servicebus config block."
}

output "blob_container_name" {
  value       = module.blob_storage.blob_container_name
  description = "Blob container name. Set as blob_container_name in the CrossGuard azure_servicebus config block."
}

output "blob_account_key" {
  value       = module.blob_storage.primary_access_key
  description = "Blob storage account key. Set as blob_account_key in the CrossGuard azure_servicebus config block."
  sensitive   = true
}

output "crossguard_plugin_config" {
  value       = module.service_bus.crossguard_plugin_config
  description = "CrossGuard plugin config values for the azure-servicebus provider — paste into System Console on both instances."
  sensitive   = true
}
