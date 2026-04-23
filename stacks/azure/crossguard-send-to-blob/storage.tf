# stacks/azure/crossguard-send-to-blob/storage.tf

locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Contact     = var.email_contact
    Stack       = "crossguard-send-to-blob"
  }
}

module "blob_storage" {
  source = "../../../modules/azure/common/blob_storage"

  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  blob_container_name = var.blob_container_name

  storage_account_replication_type = var.storage_account_replication_type
  public_network_access_enabled    = var.public_network_access_enabled

  # Leave empty if using account key auth (default). Populate only if your
  # Mattermost instances authenticate via managed identity.
  principal_ids = var.principal_ids
}
