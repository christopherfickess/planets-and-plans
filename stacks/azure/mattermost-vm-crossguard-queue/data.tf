# stacks/azure/mattermost-vm-crossguard-queue/data.tf

data "azurerm_resource_group" "crossguard" {
  name = var.resource_group_name
}
