# stacks/azure/mattermost-vm-crossguard-servicebus/blob.tf
#
# Blob Storage for CrossGuard file attachment transfers alongside the Service Bus transport.
# The CrossGuard Service Bus provider uses a separate Azure Blob Storage account for file
# payloads — Service Bus carries the message envelope, blob carries the file.
#
# Both VM managed identities are granted Storage Blob Data Contributor here even though
# the CrossGuard plugin currently uses account key auth (blob_account_key config field).
# This RBAC is applied preemptively so the environment is ready if the plugin adds managed
# identity support for blob, or if other tooling on the VMs needs direct container access.
#
# Terraform creates both VMs first implicitly — it sees the principal_id references
# and orders the VM module calls before the RBAC assignments.

module "blob_storage" {
  source = "../../../modules/azure/common/blob_storage"

  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  blob_container_name = var.blob_container_name

  # Public access is fine for testing. See blob_storage module for production guidance.
  public_network_access_enabled = true

  # Keys are static strings — Terraform resolves them at plan time.
  # Values (principal IDs) are resolved at apply time after the VMs are created.
  principal_ids = {
    vm_a = module.vm_a.vm_principal_id
    vm_b = module.vm_b.vm_principal_id
  }
}
