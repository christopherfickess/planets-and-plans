# modules/azure/common/vnet/vnet.tf


module "avm-res-network-virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1" # pick the version you want

  address_space = var.address_space
  location      = var.location
  name          = var.vnet_name
  parent_id     = data.azurerm_resource_group.mattermost_location.id

  # Nat Gateway and Subnet Configuration


  subnets = {
    "aks-subnet" = {
      name             = var.aks_subnet_name
      address_prefixes = var.aks_subnet_addresses

      nat_gateway_enabled = var.nat_gateway_enabled
      nat_gateway = {
        id = azurerm_nat_gateway.nat_gateway.id
      }

    }
    "pods-subnet" = {
      name             = var.pod_subnet_name
      address_prefixes = var.pod_subnet_addresses

      nat_gateway_enabled = var.nat_gateway_enabled
      nat_gateway = {
        id = azurerm_nat_gateway.nat_gateway.id
      }
      delegations = [{
        name = "aks-pods-delegation"
        service_delegation = {
          name = "Microsoft.ContainerService/managedClusters"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }]
    }
  }

  tags = var.tags
}
