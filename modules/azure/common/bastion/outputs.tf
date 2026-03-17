# modules/azure/common/bastion/outputs.tf

output "bastion_host_id" {
  value       = azurerm_bastion_host.main.id
  description = "The ID of the Azure Bastion host."
}

output "bastion_host_name" {
  value       = azurerm_bastion_host.main.name
  description = "The name of the Azure Bastion host."
}

output "bastion_host_fqdn" {
  value       = azurerm_bastion_host.main.dns_name
  description = "The FQDN of the Azure Bastion host."
}

output "jumpbox_vm_id" {
  value       = azurerm_linux_virtual_machine.jumpbox.id
  description = "The ID of the jumpbox VM."
}

output "jumpbox_vm_name" {
  value       = azurerm_linux_virtual_machine.jumpbox.name
  description = "The name of the jumpbox VM."
}

output "jumpbox_vm_private_ip" {
  value       = azurerm_network_interface.jumpbox.ip_configuration[0].private_ip_address
  description = "The private IP address of the jumpbox VM."
}

output "jumpbox_managed_identity_client_id" {
  value       = azurerm_user_assigned_identity.jumpbox.client_id
  description = "The client ID of the jumpbox managed identity."
}

output "jumpbox_managed_identity_principal_id" {
  value       = azurerm_user_assigned_identity.jumpbox.principal_id
  description = "The principal ID of the jumpbox managed identity."
}

output "jumpbox_ssh_public_key" {
  value       = tls_private_key.jumpbox.public_key_openssh
  description = "The SSH public key used for the jumpbox."
}

output "key_vault_name" {
  value       = azurerm_key_vault.jumpbox.name
  description = "The name of the Key Vault holding jumpbox SSH keys."
}

output "key_vault_private_key_secret_name" {
  value       = azurerm_key_vault_secret.jumpbox_private_key.name
  description = "The Key Vault secret name for the jumpbox SSH private key."
}

output "bastion_connection_instructions" {
  description = "Instructions for connecting to the jumpbox via Azure Bastion and configuring AKS access."
  value       = <<-EOT
To connect to the jumpbox using Azure Bastion (CLI):

Prerequisites:
- Azure CLI installed
- Logged into the correct subscription

Steps:

1. Create a local SSH key directory
   mkdir -p ssh/jumpbox

2. Download the private SSH key from Key Vault
   az keyvault secret show \
     --vault-name ${azurerm_key_vault.jumpbox.name} \
     --name ${azurerm_key_vault_secret.jumpbox_private_key.name} \
     --query value -o tsv > ssh/jumpbox/jumpbox.key

3. Secure the SSH key
   chmod 600 ssh/jumpbox/jumpbox.key

4. Connect using Azure Bastion
   az network bastion ssh \
     --name ${azurerm_bastion_host.main.name} \
     --resource-group ${azurerm_bastion_host.main.resource_group_name} \
     --target-resource-id ${azurerm_linux_virtual_machine.jumpbox.id} \
     --auth-type ssh-key \
     --username ${var.jumpbox_admin_username} \
     --ssh-key ssh/jumpbox/jumpbox.key

Once connected, configure AKS access:

   source setup-aks-access.sh

Or manually:

   az login --identity --username ${azurerm_user_assigned_identity.jumpbox.client_id}
   az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.aks_cluster_name} --overwrite-existing
   kubelogin convert-kubeconfig -l azurecli
   kubectl get nodes
EOT
}
