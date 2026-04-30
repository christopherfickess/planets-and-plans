# stacks/azure/crossguard-send-to-servicebus/servicebus.tf

locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Contact     = var.email_contact
    Stack       = "crossguard-send-to-servicebus"
  }
}

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

  sku      = var.sku
  capacity = var.capacity

  lock_duration                 = var.lock_duration
  max_delivery_count            = var.max_delivery_count
  default_message_ttl           = var.default_message_ttl
  max_message_size_in_kilobytes = var.max_message_size_in_kilobytes
}
