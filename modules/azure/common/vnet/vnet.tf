# modules/azure/common/vnet/vnet.tf


module "avm-res-network-virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1" # pick the version you want

  address_space = var.address_space
  location      = var.location
  name          = var.vnet_name
  parent_id     = data.azurerm_resource_group.mattermost_location.id

  # Nat Gateway and Subnet Configuration
  # multiple subnets can be defined with their own nat gateway settings
  subnets = var.subnet_configs

  tags = var.tags
}
