# stacks/azure/mattermost-vm-crossguard-queue/queue_storage.tf
#
# Both VMs are created first implicitly — Terraform sees the principal_id
# references and orders the VM module calls before the RBAC assignments.

module "queue_storage" {
  source = "../../../modules/azure/common/queue_storage"

  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  inbound_queue_name  = var.inbound_queue_name
  outbound_queue_name = var.outbound_queue_name
  blob_container_name = var.blob_container_name

  # Both VM managed identities get Storage Queue Data Contributor and Storage Blob
  # Data Contributor. Keys are static strings — Terraform resolves them at plan time.
  # Values (principal IDs) are resolved at apply time after the VMs are created.
  principal_ids = {
    vm_a = module.vm_a.vm_principal_id
    vm_b = module.vm_b.vm_principal_id
  }

  # Public access is fine for testing. See queue_storage module for production guidance.
  public_network_access_enabled = true
}
