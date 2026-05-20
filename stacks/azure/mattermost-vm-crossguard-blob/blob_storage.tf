# stacks/azure/mattermost-vm-crossguard-blob/blob_storage.tf
#
# Single shared storage account + container for both VM instances.
# Terraform creates both VMs first (implicitly, via the principal_id references)
# then applies the RBAC role assignments — no explicit depends_on needed.

module "blob_storage" {
  source = "../../../modules/azure/common/blob_storage"

  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  blob_container_name = var.blob_container_name

  # VM managed identities and (optionally) the service principal get
  # Storage Blob Data Contributor. Keys are static strings resolved at plan time.
  # Values (principal IDs) are resolved at apply time.
  principal_ids = merge(
    {
      vm_a = module.vm_a.vm_principal_id
      vm_b = module.vm_b.vm_principal_id
    },
    var.enable_service_principal ? { sp = var.sp_object_id } : {}
  )

  public_network_access_enabled = true
}
