
output "address_spaces" {
  value = module.avm-res-network-virtualnetwork.address_spaces
}

output "vnet_name" {
  value = module.avm-res-network-virtualnetwork.name
}

output "peerings" {
  value = module.avm-res-network-virtualnetwork.peerings
}

output "vnet_id" {
  value = module.avm-res-network-virtualnetwork.resource_id
}

output "resource" {
  value = module.avm-res-network-virtualnetwork.resource
}

output "subnets" {
  value = module.avm-res-network-virtualnetwork.subnets
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.nat_gateway.id
}

output "nat_public_ip_id" {
  value = azurerm_public_ip.nat_public_ip.id
}

