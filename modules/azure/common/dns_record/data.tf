data "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}