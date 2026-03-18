# stacks/azure/mattermost-bastion/outputs.tf

output "bastion_host_id" {
  value       = module.bastion.bastion_host_id
  description = "The ID of the Azure Bastion host."
}

output "bastion_host_fqdn" {
  value       = module.bastion.bastion_host_fqdn
  description = "The FQDN of the Azure Bastion host."
}

output "jumpbox_vm_id" {
  value       = module.bastion.jumpbox_vm_id
  description = "The ID of the jumpbox VM."
}

output "jumpbox_vm_name" {
  value       = module.bastion.jumpbox_vm_name
  description = "The name of the jumpbox VM."
}

output "jumpbox_vm_private_ip" {
  value       = module.bastion.jumpbox_vm_private_ip
  description = "The private IP address of the jumpbox VM."
}

output "jumpbox_managed_identity_client_id" {
  value       = module.bastion.jumpbox_managed_identity_client_id
  description = "The client ID of the jumpbox managed identity."
}

output "key_vault_name" {
  value       = module.bastion.key_vault_name
  description = "The name of the Key Vault holding jumpbox SSH keys."
}

output "bastion_connection_instructions" {
  value       = module.bastion.bastion_connection_instructions
  description = "Instructions for connecting to the jumpbox via Azure Bastion."
}
