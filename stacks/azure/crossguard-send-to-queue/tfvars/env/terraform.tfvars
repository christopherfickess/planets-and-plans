# ── Required ────────────────────────────────────────────────────────────────

# The existing resource group to deploy into.
resource_group_name = "<your-resource-group>"

# Short prefix used to name resources. Keep to 20 characters or fewer.
# The storage account name is derived from this — Azure requires it to be
# globally unique across all Azure customers.
unique_name_prefix = "<your-prefix>"

# Owner or team email — applied as a tag on all resources.
email_contact = "<your-email>"

# ── Optional — change only if needed ────────────────────────────────────────

# Azure region. Must match the region of your resource group.
# location = "eastus2"

# environment = "dev"

# These are the two physical queues Terraform creates in Azure. Both Mattermost
# instances point at the same queues but assign them opposite roles in their
# CrossGuard config — Instance A reads from crossguard-inbound and writes to
# crossguard-outbound; Instance B does the reverse. The names stay the same in
# Azure; only the role each instance assigns them changes. Only rename these if
# you need multiple independent CrossGuard links in the same storage account.
# inbound_queue_name  = "crossguard-inbound"
# outbound_queue_name = "crossguard-outbound"

# Blob container for file attachment transfers. Only needed if file_transfer_enabled = true.
# blob_container_name = "crossguard-files"

# Storage replication: LRS (default), GRS, or RAGRS.
# storage_account_replication_type = "LRS"

# Set to false and configure a private endpoint if Mattermost runs inside a VNet.
# public_network_access_enabled = true

# Only needed if your Mattermost instances authenticate via managed identity.
# Leave empty when using account key auth (the CrossGuard plugin default).
# principal_ids = {
#   instance_a = "<azure-object-id>"
#   instance_b = "<azure-object-id>"
# }
