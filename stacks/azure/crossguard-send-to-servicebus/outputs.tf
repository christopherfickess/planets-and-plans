# stacks/azure/crossguard-send-to-servicebus/outputs.tf

output "namespace_name" {
  value       = module.service_bus.namespace_name
  description = "Service Bus namespace name."
}

output "namespace_endpoint" {
  value       = module.service_bus.namespace_endpoint
  description = "AMQP endpoint for the Service Bus namespace."
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
  description = "Blob Storage endpoint URL. Set as blob_service_url in the CrossGuard azure_servicebus config block."
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
  description = "CrossGuard plugin config values for the azure-servicebus provider."
  sensitive   = true
}
