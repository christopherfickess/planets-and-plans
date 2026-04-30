# ── Required ────────────────────────────────────────────────────────────────

# The existing resource group to deploy into.
resource_group_name = "<your-resource-group>"

# Short prefix used to name resources. Keep to 20 characters or fewer.
# The Service Bus namespace and Blob storage account names are both derived from this
# and must be globally unique across all Azure customers.
unique_name_prefix = "<your-prefix>"

# Owner or team email — applied as a tag on all resources.
email_contact = "<your-email>"

# ── Optional — change only if needed ────────────────────────────────────────

# Azure region. Must match the region of your resource group.
# location = "eastus2"

# environment = "dev"

# ── Service Bus ──────────────────────────────────────────────────────────────

# SKU: Basic (testing only), Standard (default), or Premium (VNet/large messages).
# sku = "Standard"

# Messaging units — only set when sku = "Premium". Must be 0 for Standard/Basic.
# capacity = 0

# Both Mattermost instances point at the same two queues but with opposite roles:
# Instance A reads from crossguard-inbound and writes to crossguard-outbound.
# Instance B reads from crossguard-outbound and writes to crossguard-inbound.
# The queue names stay the same in Azure — only the role each instance assigns them changes.
# Only rename these if you need multiple independent CrossGuard links in the same namespace.
# inbound_queue_name  = "crossguard-inbound"
# outbound_queue_name = "crossguard-outbound"

# Message lock window. Set above your worst-case Mattermost processing latency.
# lock_duration = "PT1M"

# Dead-letter after this many failed delivery attempts. Azure default is 10.
# max_delivery_count = 10

# How long unread messages live before expiring to DLQ.
# default_message_ttl = "P14D"

# Max message size in KB — Premium only. Ignored on Standard/Basic (fixed at 256 KB).
# max_message_size_in_kilobytes = 256

# ── Blob Storage ─────────────────────────────────────────────────────────────

# Blob container for file attachment transfers. Only needed if file_transfer_enabled = true.
# blob_container_name = "crossguard-files"

# Storage replication: LRS (default), GRS, or RAGRS.
# storage_account_replication_type = "LRS"

# Set to false and configure a private endpoint if Mattermost runs inside a VNet.
# public_network_access_enabled = true

# Only needed if additional identities require managed identity access to the blob container.
# The CrossGuard plugin uses account key auth for blob — leave empty for normal deployments.
# blob_principal_ids = {
#   ops_identity = "<azure-object-id>"
# }
