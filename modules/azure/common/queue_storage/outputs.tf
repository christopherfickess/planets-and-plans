# modules/azure/common/queue_storage/outputs.tf

output "storage_account_name" {
  value       = azurerm_storage_account.crossguard.name
  description = "Name of the CrossGuard storage account."
}

output "storage_account_id" {
  value       = azurerm_storage_account.crossguard.id
  description = "Resource ID of the CrossGuard storage account."
}

output "storage_account_primary_endpoint" {
  value       = azurerm_storage_account.crossguard.primary_queue_endpoint
  description = "Primary Queue Storage endpoint URL. Use this in the CrossGuard plugin config."
}

output "storage_account_blob_endpoint" {
  value       = azurerm_storage_account.crossguard.primary_blob_endpoint
  description = "Primary Blob Storage endpoint URL."
}

output "inbound_queue_name" {
  value       = azurerm_storage_queue.inbound.name
  description = "Name of the CrossGuard inbound queue."
}

output "outbound_queue_name" {
  value       = azurerm_storage_queue.outbound.name
  description = "Name of the CrossGuard outbound queue."
}

output "blob_container_name" {
  value       = azurerm_storage_container.crossguard_files.name
  description = "Name of the CrossGuard blob container."
}

output "primary_access_key" {
  value       = azurerm_storage_account.crossguard.primary_access_key
  description = "Primary account key for the CrossGuard queue storage account. Used by the CrossGuard plugin (account key auth)."
  sensitive   = true
}

output "crossguard_plugin_config" {
  description = "Values to paste into the CrossGuard plugin connection config in Mattermost System Console."
  sensitive   = true
  value       = <<-EOT
CrossGuard Plugin — Azure Queue Provider settings:

  account_name            : ${azurerm_storage_account.crossguard.name}
  account_key             : (run: terraform output -raw storage_account_key)
  queue_service_url       : ${azurerm_storage_account.crossguard.primary_queue_endpoint}
  blob_service_url        : ${azurerm_storage_account.crossguard.primary_blob_endpoint}
  queue_name              : ${azurerm_storage_queue.inbound.name}   ← on the inbound instance
                            ${azurerm_storage_queue.outbound.name}  ← on the outbound instance
  blob_container_name     : ${azurerm_storage_container.crossguard_files.name}

To get the account key:
  terraform output -raw storage_account_key
EOT
}
