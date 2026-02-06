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
  value       = <<-EOT
    To connect to the jumpbox via Azure Bastion:
    
    1. Go to Azure Portal -> Virtual Machines -> ${azurerm_linux_virtual_machine.jumpbox.name}
    2. Click "Connect" -> "Bastion"
    3. Enter username: ${var.jumpbox_admin_username}
    4. Use your SSH key for authentication
    5. Click "Connect"
    
    ${local.aks_cluster_name != "" ? "Once connected, run:\n      ./setup-aks-access.sh\n\n    Or manually:\n      az login --identity --username ${azurerm_user_assigned_identity.jumpbox.client_id}\n      az aks get-credentials --resource-group ${data.azurerm_resource_group.mattermost_location.name} --name ${local.aks_cluster_name}\n      kubectl get nodes" : "Note: AKS cluster name was not provided. Configure AKS access manually if needed."}
  EOT
  description = "Instructions for connecting to the jumpbox via Azure Bastion"
}
