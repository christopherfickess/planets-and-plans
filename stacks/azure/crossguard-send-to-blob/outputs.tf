# stacks/azure/crossguard-send-to-blob/outputs.tf

output "storage_account_name" {
  value       = module.blob_storage.storage_account_name
  description = "Storage account name. Used as account_name in the CrossGuard plugin config."
}

output "blob_service_url" {
  value       = module.blob_storage.blob_endpoint
  description = "Primary Blob Storage endpoint URL. Used as service_url in the CrossGuard plugin config."
}

output "blob_container_name" {
  value       = module.blob_storage.blob_container_name
  description = "Blob container name. Used as blob_container_name in the CrossGuard plugin config."
}

output "storage_account_key" {
  value       = module.blob_storage.primary_access_key
  description = "Primary storage account key. Used as account_key in the CrossGuard plugin config."
  sensitive   = true
}

output "crossguard_plugin_config" {
  value       = module.blob_storage.crossguard_plugin_config
  description = "All CrossGuard plugin config values formatted for copy-paste into config-instance-a.yaml and config-instance-b.yaml."
  sensitive   = true
}
