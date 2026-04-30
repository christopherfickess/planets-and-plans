# stacks/azure/crossguard-send-to-servicebus/variables.tf

# ── Required ────────────────────────────────────────────────────────────────

variable "resource_group_name" {
  description = "Name of the existing Azure resource group to deploy into."
  type        = string
}

variable "unique_name_prefix" {
  description = <<-EOT
    Short unique prefix applied to all resource names.
    Used to derive the Service Bus namespace name (globally unique across Azure)
    and the Blob Storage account name (globally unique, max 24 lowercase alphanumeric chars).
    Keep to 20 characters or fewer. Use lowercase letters, digits, and hyphens.
    Example: "mm-cg-prod"
  EOT
  type = string
}

variable "email_contact" {
  description = "Owner or team email address applied as a tag on all resources."
  type        = string
}

# ── Optional — sensible defaults provided ───────────────────────────────────

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus2"
}

variable "environment" {
  description = "Deployment environment label applied as a tag (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

# ── Service Bus ──────────────────────────────────────────────────────────────

variable "sku" {
  description = <<-EOT
    Service Bus namespace tier.
    Basic    — queues only, no DLQ, 256 KB messages, no VNet. Testing only.
    Standard — DLQ, 256 KB messages, no VNet. Default for most deployments.
    Premium  — up to 100 MB messages, VNet/private endpoint support. ~$668/mo per MU.
               Required for VNet-isolated Mattermost deployments.
  EOT
  type    = string
  default = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  description = <<-EOT
    Messaging units for Premium SKU only. Must be 0 for Standard and Basic.
    Valid Premium values: 1, 2, 4, 8, 16.
  EOT
  type    = number
  default = 0

  validation {
    condition     = contains([0, 1, 2, 4, 8, 16], var.capacity)
    error_message = "capacity must be 0 (Standard/Basic) or 1, 2, 4, 8, 16 (Premium only)."
  }
}

variable "inbound_queue_name" {
  description = <<-EOT
    Name of the queue that receives messages sent TO Instance A from Instance B.
    Instance A reads from this queue. Instance B writes to it.
    Only rename if you need multiple independent CrossGuard links in the same namespace.
  EOT
  type    = string
  default = "crossguard-inbound"
}

variable "outbound_queue_name" {
  description = <<-EOT
    Name of the queue that carries messages sent FROM Instance A TO Instance B.
    Instance A writes to this queue. Instance B reads from it.
    Only rename if you need multiple independent CrossGuard links in the same namespace.
  EOT
  type    = string
  default = "crossguard-outbound"
}

variable "lock_duration" {
  description = <<-EOT
    ISO 8601 duration for the message lock window. Set above your worst-case
    Mattermost processing time. Valid range: PT5S to PT5M.
  EOT
  type    = string
  default = "PT1M"
}

variable "max_delivery_count" {
  description = "Max delivery attempts before a message is dead-lettered. Azure default is 10."
  type        = number
  default     = 10
}

variable "default_message_ttl" {
  description = "ISO 8601 duration for message lifetime in the queue. Expired messages move to DLQ."
  type        = string
  default     = "P14D"
}

variable "max_message_size_in_kilobytes" {
  description = <<-EOT
    Max queue message size in KB. Only applies to Premium namespaces.
    Ignored on Standard and Basic (fixed at 256 KB).
    Valid Premium range: 1 to 102400.
  EOT
  type    = number
  default = 256
}

# ── Blob Storage ─────────────────────────────────────────────────────────────

variable "blob_container_name" {
  description = "Blob container for CrossGuard file attachment transfers. Required when file_transfer_enabled = true in the plugin config."
  type        = string
  default     = "crossguard-files"
}

variable "storage_account_replication_type" {
  description = <<-EOT
    Replication type for the blob storage account.
    LRS  — single region, three copies. Sufficient for most deployments.
    GRS  — cross-region redundancy. Use when regional failover matters.
    RAGRS — cross-region with read access to the secondary.
  EOT
  type    = string
  default = "LRS"
}

variable "public_network_access_enabled" {
  description = <<-EOT
    Allow public internet access to the blob storage account.
    true  — acceptable for testing or when Mattermost reaches Azure over the internet.
    false — requires a private endpoint. Use when Mattermost runs inside a VNet.
  EOT
  type    = bool
  default = true
}

variable "blob_principal_ids" {
  description = <<-EOT
    Optional. Map of principal IDs to grant Storage Blob Data Contributor on the blob account.
    The CrossGuard plugin uses account key auth for blob (blob_account_key config field),
    so this is not required for normal plugin operation.
    Populate only if additional identities need managed identity access to the container.
    Keys must be static strings. Values are Azure object IDs.
    Example: { ops_identity = "<object-id>" }
  EOT
  type    = map(string)
  default = {}
}
