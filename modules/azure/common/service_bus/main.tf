# modules/azure/common/service_bus/main.tf

locals {
  # Service Bus namespace names: 6–50 chars, letters/digits/hyphens, must start
  # and end with a letter or digit. Azure reserves the "-sb" suffix (used internally
  # for the servicebus.windows.net domain) — use "-ns" instead.
  # Truncate to 47 chars then append "-ns" = 50 max.
  namespace_name = "${substr(lower(var.unique_name_prefix), 0, 47)}-ns"

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })

  # max_message_size_in_kilobytes is only a valid queue attribute on Premium namespaces.
  # Passing it on Standard or Basic triggers an Azure API error, so we null it out
  # for non-Premium tiers and let Azure apply the tier default (256 KB).
  max_message_size_in_kilobytes = var.sku == "Premium" ? var.max_message_size_in_kilobytes : null
}

# ----------------------------------------
# Service Bus Namespace — top-level container for queues.
# SKU determines message size limits, feature set, and cost — see variables.tf for a
# full breakdown. Default is Standard: DLQ included, 256 KB max message, no VNet.
# Switch to Premium if Mattermost runs in a VNet (private endpoint) or if payloads
# regularly exceed 256 KB without using the blob sidecar.
# ----------------------------------------
resource "azurerm_servicebus_namespace" "crossguard" {
  depends_on = [data.azurerm_resource_group.service_bus]

  name                = local.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  # capacity: messaging units for Premium only. Must be 0 for Standard/Basic —
  # Azure accepts the value but ignores it for non-Premium namespaces.
  capacity = var.capacity

  # Enforce TLS 1.2 as the floor. TLS 1.0 and 1.1 have known protocol weaknesses
  # and are prohibited by most compliance frameworks (FedRAMP, PCI-DSS, SOC 2).
  minimum_tls_version = "1.2"

  tags = merge(local.tags, { name = local.namespace_name })
}

# ----------------------------------------
# Inbound Queue — messages arriving at this Mattermost instance from the remote peer.
# The remote instance writes here; this instance reads and completes messages.
#
# PeekLock semantics (CrossGuard default): the plugin locks a message, processes it,
# then calls CompleteMessage on success or AbandonMessage on failure. Abandoned
# messages return to the queue and increment DeliveryCount toward max_delivery_count,
# after which they move to the DLQ automatically.
# ----------------------------------------
resource "azurerm_servicebus_queue" "inbound" {
  depends_on = [azurerm_servicebus_namespace.crossguard]

  name         = var.inbound_queue_name
  namespace_id = azurerm_servicebus_namespace.crossguard.id

  # lock_duration: how long a receiver holds exclusive ownership of a message.
  # If the plugin doesn't call Complete or Abandon within this window, Service Bus
  # makes the message available again (increments DeliveryCount). Set above your
  # worst-case processing latency.
  lock_duration = var.lock_duration

  # max_delivery_count: failed deliveries beyond this threshold auto-move the
  # message to the DLQ. Default 10 matches the Azure default.
  max_delivery_count = var.max_delivery_count

  default_message_ttl = var.default_message_ttl

  # Move TTL-expired messages to the DLQ rather than silently dropping them.
  # This makes message loss visible and auditable — DLQ can be monitored for alerts.
  dead_lettering_on_message_expiration = true

  # Only set for Premium namespaces — null is ignored on Standard and Basic.
  max_message_size_in_kilobytes = local.max_message_size_in_kilobytes
}

# ----------------------------------------
# Outbound Queue — messages sent from this Mattermost instance to the remote peer.
# This instance writes here; the remote instance reads and completes messages.
# Identical settings to the inbound queue — both sides of the link share the
# same operational characteristics.
# ----------------------------------------
resource "azurerm_servicebus_queue" "outbound" {
  depends_on = [azurerm_servicebus_namespace.crossguard]

  name                                 = var.outbound_queue_name
  namespace_id                         = azurerm_servicebus_namespace.crossguard.id
  lock_duration                        = var.lock_duration
  max_delivery_count                   = var.max_delivery_count
  default_message_ttl                  = var.default_message_ttl
  dead_lettering_on_message_expiration = true
  max_message_size_in_kilobytes        = local.max_message_size_in_kilobytes
}

# ----------------------------------------
# SAS Authorization Rule — Send + Listen only, no Manage.
#
# Why not RootManageSharedAccessKey: that key grants Manage rights, which allows
# creating/deleting queues, modifying namespace config, and generating new SAS keys.
# The CrossGuard plugin only needs to send and receive messages — granting Manage
# is a security liability if the connection string is ever exposed.
#
# Why namespace-level rather than queue-level: the CrossGuard plugin takes a single
# connection_string per provider config, which the SDK uses to create a namespace
# client. The client then targets specific queues by name. Queue-level rules would
# require separate connection strings per queue (inbound and outbound), which the
# plugin's current config schema doesn't support. Namespace Send+Listen is the
# practical least-privilege option given the plugin's interface.
# ----------------------------------------
resource "azurerm_servicebus_namespace_authorization_rule" "crossguard" {
  depends_on = [azurerm_servicebus_namespace.crossguard]

  name         = "crossguard-send-listen"
  namespace_id = azurerm_servicebus_namespace.crossguard.id

  listen = true
  send   = true
  manage = false
}
