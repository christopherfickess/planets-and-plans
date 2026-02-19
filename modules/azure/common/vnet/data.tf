data "azurerm_resource_group" "mattermost_location" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnets" {
  depends_on = [module.avm-res-network-virtualnetwork]

  for_each = {
    for k, v in var.subnet_configs : k => v
    if lookup(v, "nat_gateway_enabled", false) == true
  }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = "${var.unique_name_prefix}-${var.vnet_name}"
}
