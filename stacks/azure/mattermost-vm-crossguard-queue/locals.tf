# stacks/azure/mattermost-vm-crossguard-queue/locals.tf

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
    "CrossGuard Plugin -- Azure Queue Provider (Service Principal auth):",
    "",
    "  auth_mode            : service-principal",
    "  azure_cloud          : public",
    "  tenant_id            : (from 1Password shared note)",
    "  client_id            : (from 1Password shared note)",
    "  client_secret        : (from 1Password shared note)",
    "  queue_service_url    : ${module.queue_storage.storage_account_primary_endpoint}",
    "  blob_service_url     : ${module.queue_storage.storage_account_blob_endpoint}",
    "  queue_name           : ${module.queue_storage.inbound_queue_name}   (inbound instance)",
    "                         ${module.queue_storage.outbound_queue_name}  (outbound instance)",
    "  blob_container_name  : ${module.queue_storage.blob_container_name}",
  ]) : null
}
