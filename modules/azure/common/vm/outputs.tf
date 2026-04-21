# modules/azure/common/vm/outputs.tf

output "vm_id" {
  value       = azurerm_linux_virtual_machine.vm.id
  description = "Resource ID of the Mattermost VM."
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.vm.name
  description = "Name of the Mattermost VM."
}

output "vm_principal_id" {
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
  description = "Principal ID of the VM's system-assigned managed identity. Pass this to the queue_storage module to grant storage RBAC roles."
}

output "vm_private_ip" {
  value       = azurerm_network_interface.vm.ip_configuration[0].private_ip_address
  description = "Private IP address of the VM NIC."
}

output "vm_public_ip" {
  value       = var.public_ip_enabled ? azurerm_public_ip.vm[0].ip_address : null
  description = "Public IP address of the VM. Null when public_ip_enabled is false."
}

output "vm_fqdn" {
  value       = var.public_ip_enabled ? azurerm_public_ip.vm[0].fqdn : null
  description = "Azure DNS FQDN for the VM — <prefix>-vm.<region>.cloudapp.azure.com. Use this as the Mattermost SiteURL host."
}

output "key_vault_name" {
  value       = azurerm_key_vault.vm.name
  description = "Name of the Key Vault holding the VM SSH keys."
}

output "ssh_private_key_secret_name" {
  value       = azurerm_key_vault_secret.vm_private_key.name
  description = "Key Vault secret name for the SSH private key."
}

output "connection_instructions" {
  description = "Exact commands to SSH into the VM and verify Mattermost is running."
  value       = <<-EOT
========================================================
 Mattermost VM: ${azurerm_linux_virtual_machine.vm.name}
========================================================

-- Prerequisites --
  az login                          # skip if already logged in
  az account set --subscription <your-subscription-id>

-- 1. Pull the SSH key from Key Vault --
  az keyvault secret show \
    --vault-name ${azurerm_key_vault.vm.name} \
    --name ${azurerm_key_vault_secret.vm_private_key.name} \
    --query value -o tsv > ~/.ssh/${azurerm_linux_virtual_machine.vm.name}.pem && \
  chmod 600 ~/.ssh/${azurerm_linux_virtual_machine.vm.name}.pem

-- 2. SSH in --
  ssh -i ~/.ssh/${azurerm_linux_virtual_machine.vm.name}.pem ${var.admin_username}@${var.public_ip_enabled ? azurerm_public_ip.vm[0].fqdn : azurerm_network_interface.vm.ip_configuration[0].private_ip_address}

-- 3. Once on the VM: wait for cloud-init to finish --
  # cloud-init runs Docker install + Mattermost startup on first boot.
  # This takes 2-4 minutes. Run this to block until it completes:
  sudo cloud-init status --wait

-- 4. Verify Docker and Mattermost container --
  sudo docker ps
  sudo docker compose -f /opt/mattermost/docker-compose.yml ps

-- 5. Tail Mattermost logs --
  sudo docker compose -f /opt/mattermost/docker-compose.yml logs -f mattermost

-- 6. Smoke-test the HTTP endpoint from the VM --
  curl -sf --retry 5 --retry-delay 10 --retry-all-errors \
    http://localhost:8065/api/v4/system/ping | python3 -m json.tool
  # Retries up to 5 times with 10s gaps — Postgres needs ~30s to be ready on first boot.
  # Healthy response: { "status": "OK", ... }

-- 7. Reach it from your browser --
  ${var.public_ip_enabled ? "http://${azurerm_public_ip.vm[0].fqdn}:8065" : "http://${azurerm_network_interface.vm.ip_configuration[0].private_ip_address}:8065 (requires VPN or bastion)"}

========================================================
EOT
}
