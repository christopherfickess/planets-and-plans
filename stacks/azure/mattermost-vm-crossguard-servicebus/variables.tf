# stacks/azure/mattermost-vm-crossguard-servicebus/variables.tf

variable "unique_name_prefix" {
  description = "Prefix applied to all resource names — use a short, unique identifier (e.g. mattermost-cg-dev)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the existing resource group to deploy into"
  type        = string
}

variable "email_contact" {
  description = "Owner email address — applied as a tag on all resources"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR block for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vm_a_subnet_cidr" {
  description = "CIDR block for VM A's subnet. Each VM gets its own subnet to avoid NSG association conflicts."
  type        = string
  default     = "10.10.1.0/24"
}

variable "vm_b_subnet_cidr" {
  description = "CIDR block for VM B's subnet. Each VM gets its own subnet to avoid NSG association conflicts."
  type        = string
  default     = "10.10.2.0/24"
}

variable "vm_size" {
  description = "Azure VM SKU for the Mattermost host"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Linux admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to reach port 22. Restrict to your IP in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "mattermost_version" {
  description = "Mattermost Docker image tag to deploy (e.g. 11.6.0)"
  type        = string
  default     = "11.6.0"
}

# ── Service Principal (externally created) ───────────────────────────────────

variable "enable_service_principal" {
  description = <<-EOT
    Enable service principal RBAC for the CrossGuard plugin. When true, Terraform
    assigns Azure Service Bus Data Sender, Azure Service Bus Data Receiver, and
    Storage Blob Data Contributor to sp_object_id.
    Requires sp_object_id to be set.
  EOT
  type    = bool
  default = true
}

variable "sp_object_id" {
  description = <<-EOT
    Object ID of the service principal (NOT the client/application ID).
    Used for RBAC role assignments. Find it in Azure Portal under
    Enterprise Applications, or ask your AD admin.
    az ad sp show --id <client-id> --query id -o tsv
  EOT
  type    = string
  default = ""
}


variable "key_vault_reader_object_ids" {
  description = <<-EOT
    Map of Azure AD object IDs granted Key Vault Secrets User on each VM's Key Vault.
    Add your personal identity here when Terraform runs as a service principal so you
    can still fetch SSH keys with az keyvault secret show under az login.
    Find your object ID: az ad signed-in-user show --query id -o tsv
  EOT
  type    = map(string)
  default = {}
}

# ── Service Bus ──────────────────────────────────────────────────────────────

variable "inbound_queue_name" {
  description = "Service Bus queue name for CrossGuard inbound messages"
  type        = string
  default     = "crossguard-inbound"
}

variable "outbound_queue_name" {
  description = "Service Bus queue name for CrossGuard outbound messages"
  type        = string
  default     = "crossguard-outbound"
}

variable "service_bus_sku" {
  description = <<-EOT
    Service Bus namespace tier.
    Basic    — queues only, no DLQ, 256 KB messages, no VNet. Testing only.
    Standard — DLQ, 256 KB messages, no VNet. Default for most deployments.
    Premium  — up to 100 MB messages, VNet/private endpoint support. ~$668/mo per MU.
  EOT
  type    = string
  default = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.service_bus_sku)
    error_message = "service_bus_sku must be one of: Basic, Standard, Premium."
  }
}

variable "service_bus_capacity" {
  description = "Messaging units for Premium SKU only. Must be 0 for Standard and Basic. Valid Premium values: 1, 2, 4, 8, 16."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 2, 4, 8, 16], var.service_bus_capacity)
    error_message = "service_bus_capacity must be 0 (Standard/Basic) or 1, 2, 4, 8, 16 (Premium only)."
  }
}

variable "lock_duration" {
  description = "ISO 8601 duration for the message lock window. Set above your worst-case Mattermost processing latency. Valid range: PT5S to PT5M."
  type        = string
  default     = "PT1M"
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
  description = "Max queue message size in KB. Only applies to Premium namespaces — ignored on Standard/Basic (fixed at 256 KB)."
  type        = number
  default     = 256
}

# ── Blob Storage ─────────────────────────────────────────────────────────────

variable "blob_container_name" {
  description = "Blob container name for CrossGuard file transfers. Required when file_transfer_enabled = true in the plugin config."
  type        = string
  default     = "crossguard-files"
}
