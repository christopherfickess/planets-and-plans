# stacks/azure/mattermost-bastion/outputs.tf

# Bastion Host Outputs
output "bastion_host_id" {
  value       = azurerm_bastion_host.main.id
  description = "The ID of the Azure Bastion host"
}

output "bastion_host_fqdn" {
  value       = azurerm_bastion_host.main.dns_name
  description = "The FQDN of the Azure Bastion host"
}

# output "bastion_public_ip" {
#   value       = data.azurerm_public_ip.bastion.ip_address
#   description = "The public IP address of the Azure Bastion host"
# }

output "bastion_subnet_id" {
  value       = data.azurerm_subnet.bastion.id
  description = "The ID of the Azure Bastion subnet"
}

# Jumpbox VM Outputs
output "jumpbox_vm_id" {
  value       = azurerm_linux_virtual_machine.jumpbox.id
  description = "The ID of the jumpbox VM"
}

output "jumpbox_vm_name" {
  value       = azurerm_linux_virtual_machine.jumpbox.name
  description = "The name of the jumpbox VM"
}

output "jumpbox_vm_private_ip" {
  value       = azurerm_network_interface.jumpbox.ip_configuration[0].private_ip_address
  description = "The private IP address of the jumpbox VM"
}

output "jumpbox_subnet_id" {
  value       = data.azurerm_subnet.jumpbox.id
  description = "The ID of the jumpbox subnet"
}

# Managed Identity Outputs
output "jumpbox_managed_identity_id" {
  value       = azurerm_user_assigned_identity.jumpbox.client_id
  description = "The client ID of the jumpbox managed identity"
}

output "jumpbox_managed_identity_principal_id" {
  value       = azurerm_user_assigned_identity.jumpbox.principal_id
  description = "The principal ID of the jumpbox managed identity"
}

# SSH Key Output
output "jumpbox_ssh_public_key" {
  value       = tls_private_key.jumpbox.public_key_openssh
  description = "The SSH public key used for the jumpbox"
}

# Connection Instructions
output "bastion_connection_instructions" {
  value = <<-EOT
To connect to the jumpbox using Azure Bastion (CLI):

Prerequisites:
- Azure CLI installed
- Logged into the correct subscription

Steps:

1. Create a local SSH key directory
   mkdir -p ssh/jumpbox_${var.environment}

2. Download the private SSH key from Key Vault
   az keyvault secret show \
     --vault-name ${azurerm_key_vault.jumpbox.name} \
     --name ${azurerm_key_vault_secret.jumpbox_private_key.name} \
     --query value -o tsv > ssh/jumpbox_${var.environment}/jumpbox_${var.environment}.key

3. Secure the SSH key
   chmod 600 ssh/jumpbox_${var.environment}/jumpbox_${var.environment}.key

4. Connect using Azure Bastion
   az network bastion ssh \
     --name ${azurerm_bastion_host.main.name} \
     --resource-group ${azurerm_bastion_host.main.resource_group_name} \
     --target-resource-id ${azurerm_linux_virtual_machine.jumpbox.id} \
     --auth-type ssh-key \
     --username ${var.jumpbox_admin_username} \
     --ssh-key ssh/jumpbox_${var.environment}/jumpbox_${var.environment}.key

${local.aks_cluster_name != "" ? <<-AKS

Once connected to the jumpbox, configure AKS access:

Option 1: Using Builtin Scripts and README

1. The jumpbox is pre-configured with a setup script and README located in the home directory. Follow the instructions in the README for AKS access.

cat README.md

source setup-aks-access.sh

Option 2: Manual Steps if you want to configure manually or troubleshoot:

1. Login using the VM managed identity
   az login --identity --username ${azurerm_user_assigned_identity.jumpbox.client_id}

2. Fetch AKS credentials
   az aks get-credentials \
     --resource-group ${data.azurerm_resource_group.mattermost_location.name} \
     --name ${local.aks_cluster_name} \
     --overwrite-existing

3. Convert kubeconfig for Azure AD
   kubelogin convert-kubeconfig -l azurecli

4. Verify access
   kubectl get nodes
AKS
: ""}
EOT

description = "Instructions for connecting to the jumpbox via Azure Bastion and configuring AKS access"
}

