# stacks/azure/mattermost-vm-crossguard-blob/data.tf

data "azurerm_resource_group" "crossguard_blob" {
  name = var.resource_group_name
}
