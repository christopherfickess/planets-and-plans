variable "unique_name_prefix" {
  description = <<-EOT
    Prefix applied to all resource names. Used to derive the Service Bus namespace name,
    which must be globally unique across all Azure customers.
    Stick to lowercase letters, digits, and hyphens. Start with a letter.
    Keep to 45 characters or fewer — the module appends "-sb" to form the namespace name.
    Example: "mm-cg-prod"
  EOT
  type = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
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

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}

variable "email_contact" {
  description = "Owner email address — applied as a tag on all resources"
  type        = string
}

variable "sku" {
  description = <<-EOT
    Service Bus namespace tier. Controls message size limits, feature set, and cost.

    Basic    — queues only, no DLQ, 256 KB max message size, no VNet support.
               ~$0.05/million ops. Use only for throwaway testing.

    Standard — queues + topics, DLQ, 256 KB max message size, no VNet support.
               ~$10/mo base + $0.10/million ops. Default — covers most deployments.

    Premium  — up to 100 MB messages (matches CrossGuard plugin max), VNet/private
               endpoint support, dedicated capacity. ~$668/mo per messaging unit.
               Required when Mattermost runs in a VNet with no public internet egress,
               or when file payloads larger than 256 KB must transit the queue directly
               rather than via blob sidecar.
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
    Messaging units — only relevant for Premium SKU.
    Must be 0 for Standard and Basic (Azure ignores the value).
    For Premium, valid values are 1, 2, 4, 8, or 16.
    1 MU handles roughly 1,000 messages/second. Scale up if you see throttling.
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
    Service Bus queue for messages arriving at this Mattermost instance from the remote peer.
    The remote instance writes here; this instance reads from it.
  EOT
  type    = string
  default = "crossguard-inbound"
}

variable "outbound_queue_name" {
  description = <<-EOT
    Service Bus queue for messages sent from this Mattermost instance to the remote peer.
    This instance writes here; the remote instance reads from it.
  EOT
  type    = string
  default = "crossguard-outbound"
}

variable "lock_duration" {
  description = <<-EOT
    ISO 8601 duration for the exclusive lock a receiver holds on a message before Service Bus
    makes it available for redelivery. Set this longer than your worst-case Mattermost
    message processing time to avoid spurious redeliveries under load.
    Valid range: PT5S to PT5M. Example values: "PT30S", "PT1M", "PT5M".
  EOT
  type    = string
  default = "PT1M"
}

variable "max_delivery_count" {
  description = <<-EOT
    Maximum delivery attempts before Service Bus dead-letters the message.
    Once exceeded, the message moves to the DLQ for manual inspection.
    Azure default is 10. Lower to 3–5 for faster DLQ promotion on stuck messages.
  EOT
  type    = number
  default = 10
}

variable "default_message_ttl" {
  description = <<-EOT
    ISO 8601 duration for how long unread messages live in the queue before expiring.
    Expired messages move to the DLQ (dead_lettering_on_message_expiration is always enabled).
    Example values: "PT1H" (1 hour), "P1D" (1 day), "P14D" (14 days, default).
  EOT
  type    = string
  default = "P14D"
}

variable "max_message_size_in_kilobytes" {
  description = <<-EOT
    Maximum queue message size in kilobytes. Only applies to Premium namespaces —
    ignored on Standard and Basic where the limit is fixed at 256 KB.
    Valid range for Premium: 1 to 102400 (100 MB).
    The CrossGuard plugin default payload is 192 KB; only raise this if large file
    payloads must transit the queue directly rather than via the blob sidecar.
  EOT
  type    = number
  default = 256
}
