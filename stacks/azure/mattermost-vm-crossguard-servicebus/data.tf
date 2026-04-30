# stacks/azure/mattermost-vm-crossguard-servicebus/data.tf

data "azurerm_resource_group" "crossguard" {
  name = var.resource_group_name
}
