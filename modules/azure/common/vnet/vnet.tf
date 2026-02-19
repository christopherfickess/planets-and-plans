# modules/azure/common/vnet/vnet.tf

# Transform subnet configs so the Azure AVM module receives nat_gateway = { id = "..." }
# when nat_gateway_enabled. This avoids drift from separate azurerm_subnet_nat_gateway_association
# which caused subnet/NAT association replacement on every plan.
locals {
  subnet_configs_for_azure = {
    for k, v in var.subnet_configs : k => merge(
      v,
      lookup(v, "nat_gateway_enabled", false) == true && lookup(v, "nat_gateway_id", "") != ""
      ? { nat_gateway = { id = v.nat_gateway_id } }
      : {}
    )
  }
}

module "avm-res-network-virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1" # pick the version you want

  address_space = var.address_space
  location      = var.location
  name          = "${var.unique_name_prefix}-${var.vnet_name}"
  parent_id     = data.azurerm_resource_group.mattermost_location.id

  # Nat Gateway and Subnet Configuration
  # Subnets with nat_gateway_enabled get nat_gateway passed so Azure module creates them attached
  subnets = local.subnet_configs_for_azure

  tags = var.tags
}
