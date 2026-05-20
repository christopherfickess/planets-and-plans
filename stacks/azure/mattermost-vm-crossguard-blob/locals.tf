# stacks/azure/mattermost-vm-crossguard-blob/locals.tf

resource "time_static" "deployment_date" {}

locals {
  tags = {
    Date           = time_static.deployment_date.rfc3339
    Email          = var.email_contact
    Env            = var.environment
    Resource_Group = var.resource_group_name
    Type           = "Mattermost CrossGuard Blob VM"
    Deployment     = "Terraform"
  }

  # SP plugin config helper text. Credentials (tenant_id, client_id,
  # client_secret) come from the shared 1Password note, not Terraform.
  sp_plugin_config = var.enable_service_principal ? join("\n", [
    "CrossGuard Plugin -- Azure Blob Provider (Service Principal auth):",
    "",
    "  auth_mode            : service-principal",
    "  azure_cloud          : public",
    "  tenant_id            : (from 1Password shared note)",
    "  client_id            : (from 1Password shared note)",
    "  client_secret        : (from 1Password shared note)",
    "  service_url          : ${module.blob_storage.blob_endpoint}",
    "  blob_container_name  : ${module.blob_storage.blob_container_name}",
  ]) : null
}
