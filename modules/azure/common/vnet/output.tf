
# output "vnet_id" {
#   value = data.azurerm_virtual_network.vnet.id
# }

output "vnet" {
  value = module.avm-res-network-virtualnetwork
}

# output "subnets" {
#   value = {
#     aks  = data.azurerm_subnet.aks.id
#     pods = data.azurerm_subnet.pods.id
#   }
#   description = "Map of subnets in the VNet."
# }

# output "vnet_name" {
#   value = azurerm_virtual_network.vnet.name
# }

# output "aks_subnet_id" {
#   value = module.avm-res-network-virtualnetwork.subnets["aks-subnet"].id
# }

# output "pods_subnet_id" {
#   value = module.avm-res-network-virtualnetwork.subnets["pods-subnet"].id
# }
