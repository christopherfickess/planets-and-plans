
output "vnet_id" {
  value = data.azurerm_virtual_network.vnet.id
}

output "subnets" {
  value = {
    aks  = data.azurerm_subnet.aks.id
    pods = data.azurerm_subnet.pods.id
  }
  description = "Map of subnets in the VNet."
}

output "vnet_name" {
  value       = var.vnet_name
  description = "Name of the VNet."
}

