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

# Blob container name — only change if you need multiple CrossGuard deployments
# in the same storage account.
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
