data "azurerm_resource_group" "mattermost_location" {
  name = var.resource_group_name
}

# data "azurerm_subnet" "aks" {
#   name                 = "aks-subnet"
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.resource_group_name
# }

# data "azurerm_subnet" "pods" {
#   name                 = "pods-subnet"
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.resource_group_name
# }

# data "azurerm_virtual_network" "vnet" {
#   name                = var.vnet_name
#   resource_group_name = var.resource_group_name
# }

data "azurerm_subnet" "subnets" {
  for_each = {
    for k, v in var.subnet_configs : k => v
    if lookup(v, "nat_gateway_enabled", false) == true
  }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
}
