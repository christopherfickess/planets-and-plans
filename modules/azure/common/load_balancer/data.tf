data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.unique_name_prefix}-${var.vnet_name}"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "lb_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}
