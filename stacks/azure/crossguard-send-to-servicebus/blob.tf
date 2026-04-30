# stacks/azure/crossguard-send-to-servicebus/blob.tf
#
# Blob Storage account for CrossGuard file attachment transfers.
# The CrossGuard Service Bus provider uses a separate Azure Blob Storage account
# for file payloads — Service Bus carries the message envelope, blob carries the file.
# This is required when file_transfer_enabled = true on any CrossGuard connection.

module "blob_storage" {
  source = "../../../modules/azure/common/blob_storage"

  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  blob_container_name              = var.blob_container_name
  storage_account_replication_type = var.storage_account_replication_type
  public_network_access_enabled    = var.public_network_access_enabled

  # The CrossGuard plugin authenticates to blob storage using account key (blob_account_key)
  # not managed identity, so RBAC assignments are not needed here.
  # Populate this only if you have identities that need managed identity access to the container.
  principal_ids = var.blob_principal_ids
}
