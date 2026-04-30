# stacks/azure/mattermost-vm-crossguard-servicebus/servicebus.tf
#
# Service Bus namespace and queues for CrossGuard message transport.
# The CrossGuard plugin authenticates using a connection string (SAS Send+Listen rule)
# scoped to this namespace — managed identity auth is not currently supported by the plugin.
# No principal_ids are passed here for that reason.

module "service_bus" {
  source = "../../../modules/azure/common/service_bus"

  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  inbound_queue_name  = var.inbound_queue_name
  outbound_queue_name = var.outbound_queue_name

  sku      = var.service_bus_sku
  capacity = var.service_bus_capacity

  lock_duration                 = var.lock_duration
  max_delivery_count            = var.max_delivery_count
  default_message_ttl           = var.default_message_ttl
  max_message_size_in_kilobytes = var.max_message_size_in_kilobytes
}
