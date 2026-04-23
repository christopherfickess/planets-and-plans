# stacks/azure/crossguard-send-to-queue/variables.tf

# ── Required ────────────────────────────────────────────────────────────────

variable "resource_group_name" {
  description = "Name of the existing Azure resource group to deploy into."
  type        = string
}

variable "unique_name_prefix" {
  description = <<-EOT
    Short unique prefix applied to all resource names.
    Used to derive the storage account name — Azure limits storage account names
    to 24 lowercase alphanumeric characters. Keep this to 20 characters or fewer.
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

variable "inbound_queue_name" {
  description = <<-EOT
    Name of the queue that receives messages sent TO Instance A from Instance B.
    Instance A reads from this queue. Instance B writes to it.
    Default matches the CrossGuard plugin default — only change if you need multiple deployments in the same account.
  EOT
  type    = string
  default = "crossguard-inbound"
}

variable "outbound_queue_name" {
  description = <<-EOT
    Name of the queue that carries messages sent FROM Instance A TO Instance B.
    Instance A writes to this queue. Instance B reads from it.
    Default matches the CrossGuard plugin default — only change if you need multiple deployments in the same account.
  EOT
  type    = string
  default = "crossguard-outbound"
}

variable "blob_container_name" {
  description = "Blob container used for CrossGuard file attachment transfers. Only required if file_transfer_enabled is true in the plugin config."
  type        = string
  default     = "crossguard-files"
}

variable "storage_account_replication_type" {
  description = <<-EOT
    Replication type for the storage account.
    LRS  — single region, three copies. Sufficient for most deployments.
    GRS  — cross-region redundancy. Use when regional failover matters.
    RAGRS — cross-region with read access to the secondary.
  EOT
  type    = string
  default = "LRS"
}

variable "principal_ids" {
  description = <<-EOT
    Optional. Map of principal IDs (managed identities, service principals) to grant
    Storage Queue Data Contributor and Storage Blob Data Contributor on the storage account.
    Only needed if your Mattermost instances authenticate via managed identity rather than account key.
    The CrossGuard plugin uses account key auth by default — leave this empty unless you have a specific reason to use managed identity.
    Keys must be static strings. Values are the Azure object IDs of the identities.
    Example: { instance_a = "<object-id>", instance_b = "<object-id>" }
  EOT
  type    = map(string)
  default = {}
}

variable "public_network_access_enabled" {
  description = <<-EOT
    Allow access to the storage account from the public internet.
    true  — acceptable for testing or when Mattermost instances reach Azure over the internet.
    false — requires a private endpoint. Use this when Mattermost runs inside a VNet.
  EOT
  type    = bool
  default = true
}
