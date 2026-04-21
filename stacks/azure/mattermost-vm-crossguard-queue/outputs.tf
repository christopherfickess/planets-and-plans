# stacks/azure/mattermost-vm-crossguard-queue/outputs.tf

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

output "storage_account_name" {
  value       = module.queue_storage.storage_account_name
  description = "CrossGuard queue storage account name."
}

output "vm_a_connection_instructions" {
  value       = module.vm_a.connection_instructions
  description = "SSH connection steps for VM A."
}

output "vm_b_connection_instructions" {
  value       = module.vm_b.connection_instructions
  description = "SSH connection steps for VM B."
}

output "storage_account_key" {
  value       = module.queue_storage.primary_access_key
  description = "Primary account key for the CrossGuard queue storage account."
  sensitive   = true
}

output "crossguard_plugin_config" {
  value       = module.queue_storage.crossguard_plugin_config
  description = "CrossGuard queue provider settings — paste these into System Console on both instances."
  sensitive   = true
}
