# stacks/azure/mattermost-vm-crossguard-servicebus/service_principal.tf
#
# Service principal RBAC for CrossGuard plugin service-principal auth mode.
#
# The app registration and client secret are created outside Terraform
# (by an AD admin or via az cli) and passed in via tfvars. Terraform only
# manages the RBAC role assignments so the SP can access Service Bus and Blob.
#
# Set enable_service_principal = true and provide sp_object_id to activate.
#
# RBAC assignments:
#   - Storage Blob Data Contributor: assigned via blob_storage module principal_ids
#   - Azure Service Bus Data Sender + Receiver: assigned here (the service_bus
#     module doesn't have a principal_ids interface since it was built for SAS auth)

resource "azurerm_role_assignment" "sp_servicebus_sender" {
  count = var.enable_service_principal ? 1 : 0

  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = var.sp_object_id
}

resource "azurerm_role_assignment" "sp_servicebus_receiver" {
  count = var.enable_service_principal ? 1 : 0

  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = var.sp_object_id
}
