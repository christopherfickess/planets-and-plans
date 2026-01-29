module "avm-res-network-virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1" # pick the version you want

  address_space = var.address_space
  location      = var.location
  name          = var.vnet_name
  parent_id     = var.resource_group_name

  subnets = {
    "aks-subnet" = {
      name             = "aks-subnet"
      address_prefixes = var.aks_subnet_addresses
    }
    "pods-subnet" = {
      name             = "pods-subnet"
      address_prefixes = var.pod_subnet_addresses
    }
  }

  tags = {
    environment    = var.environment
    owner          = "platform"
    managed_by     = "terraform"
    email_contact  = var.email_contact
    location       = var.location
    module_version = var.module_version
  }
}
