# modules/azure/common/service_bus/outputs.tf

output "namespace_name" {
  value       = azurerm_servicebus_namespace.crossguard.name
  description = "Name of the CrossGuard Service Bus namespace."
}

output "namespace_id" {
  value       = azurerm_servicebus_namespace.crossguard.id
  description = "Resource ID of the CrossGuard Service Bus namespace."
}

output "namespace_endpoint" {
  value       = azurerm_servicebus_namespace.crossguard.endpoint
  description = "AMQP endpoint for the Service Bus namespace (e.g. sb://mattermost-cg-dev-ns.servicebus.windows.net/)."
}

output "inbound_queue_name" {
  value       = azurerm_servicebus_queue.inbound.name
  description = "Inbound queue name. Set as queue_name on the receiving connection in the CrossGuard plugin config."
}

output "outbound_queue_name" {
  value       = azurerm_servicebus_queue.outbound.name
  description = "Outbound queue name. Set as queue_name on the sending connection in the CrossGuard plugin config."
}

output "authorization_rule_name" {
  value       = azurerm_servicebus_namespace_authorization_rule.crossguard.name
  description = "Name of the Send+Listen SAS authorization rule. Scoped to Send and Listen only — no Manage rights."
}

output "connection_string" {
  value       = azurerm_servicebus_namespace_authorization_rule.crossguard.primary_connection_string
  description = <<-EOT
    Primary SAS connection string (Send+Listen, no Manage). Set as connection_string in
    the CrossGuard plugin's azure_servicebus config block.
    To retrieve: terraform output -raw connection_string
  EOT
  sensitive = true
}

output "secondary_connection_string" {
  value       = azurerm_servicebus_namespace_authorization_rule.crossguard.secondary_connection_string
  description = <<-EOT
    Secondary SAS connection string. Use for zero-downtime key rotation:
    1. Update plugin config to this value and reload.
    2. Regenerate the primary key in Azure Portal.
    3. Update plugin config back to the new primary.
    To retrieve: terraform output -raw secondary_connection_string
  EOT
  sensitive = true
}

output "crossguard_plugin_config" {
  description = "Values to paste into the CrossGuard plugin connection config in Mattermost System Console."
  sensitive   = true
  value       = <<-EOT
CrossGuard Plugin — Azure Service Bus Provider settings:

  provider          : azure-servicebus
  connection_string : (run: terraform output -raw connection_string)

  Inbound connection (this instance receives):
    queue_name      : ${azurerm_servicebus_queue.inbound.name}

  Outbound connection (this instance sends):
    queue_name      : ${azurerm_servicebus_queue.outbound.name}

  If file_transfer_enabled = true, also configure in the azure_servicebus block:
    blob_service_url     : (from blob_storage module: blob_endpoint output)
    blob_account_name    : (from blob_storage module: storage_account_name output)
    blob_account_key     : (run: terraform output -raw blob_account_key)
    blob_container_name  : (from blob_storage module: blob_container_name output)

To retrieve the connection string:
  terraform output -raw connection_string
EOT
}
