# stacks/azure/mattermost-vm-crossguard-servicebus/locals.tf

resource "time_static" "deployment_date" {}

locals {
  tags = {
    Date           = time_static.deployment_date.rfc3339
    Email          = var.email_contact
    Env            = var.environment
    Resource_Group = var.resource_group_name
    Type           = "Mattermost CrossGuard VM"
    Deployment     = "Terraform"
  }

  # Credentials (tenant_id, client_id, client_secret) come from the shared
  # 1Password note, not Terraform.
  sp_plugin_config = var.enable_service_principal ? join("\n", [
    "CrossGuard Plugin -- Azure Service Bus Provider (Service Principal auth):",
    "",
    "  auth_mode              : service-principal",
    "  azure_cloud            : public",
    "  tenant_id              : (from 1Password shared note)",
    "  client_id              : (from 1Password shared note)",
    "  client_secret          : (from 1Password shared note)",
    "  service_bus_namespace  : ${module.service_bus.namespace_name}.servicebus.windows.net",
    "",
    "  Inbound connection (this instance receives):",
    "    queue_name           : ${module.service_bus.inbound_queue_name}",
    "",
    "  Outbound connection (this instance sends):",
    "    queue_name           : ${module.service_bus.outbound_queue_name}",
    "",
    "  If file_transfer_enabled = true, also configure in the azure_servicebus block:",
    "    blob_service_url     : ${module.blob_storage.blob_endpoint}",
    "    blob_container_name  : ${module.blob_storage.blob_container_name}",
    "    (blob credentials are inherited from the parent SP in service-principal mode)",
  ]) : null
}
