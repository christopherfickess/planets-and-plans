# stacks/azure/crossguard-send-to-queue/outputs.tf

output "storage_account_name" {
  value       = module.queue_storage.storage_account_name
  description = "Storage account name. Used as account_name in the CrossGuard plugin config."
}

output "queue_service_url" {
  value       = module.queue_storage.storage_account_primary_endpoint
  description = "Primary Queue Storage endpoint URL. Used as queue_service_url in the CrossGuard plugin config."
}

output "blob_service_url" {
  value       = module.queue_storage.storage_account_blob_endpoint
  description = "Primary Blob Storage endpoint URL. Used as blob_service_url in the CrossGuard plugin config."
}

output "inbound_queue_name" {
  value       = module.queue_storage.inbound_queue_name
  description = "Inbound queue name. Instance A reads from this queue — set as queue_name on Instance A's inbound connection."
}

output "outbound_queue_name" {
  value       = module.queue_storage.outbound_queue_name
  description = "Outbound queue name. Instance A writes to this queue — set as queue_name on Instance A's outbound connection. Instance B's inbound connection uses this same name."
}

output "blob_container_name" {
  value       = module.queue_storage.blob_container_name
  description = "Blob container name. Used as blob_container_name in the CrossGuard plugin config."
}

output "storage_account_key" {
  value       = module.queue_storage.primary_access_key
  description = "Primary storage account key. Used as account_key in the CrossGuard plugin config."
  sensitive   = true
}

output "crossguard_plugin_config" {
  value       = module.queue_storage.crossguard_plugin_config
  description = "All CrossGuard plugin config values formatted for copy-paste into config-instance-a.yaml and config-instance-b.yaml."
  sensitive   = true
}
