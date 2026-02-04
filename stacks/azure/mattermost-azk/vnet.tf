# stacks/azure/mattermost-azk/vnet.tf


module "mattermost_vnet" {
  source = "../../../modules/azure/common/vnet"

  unique_name_prefix = local.base_identifier

  vnet_name           = var.vnet_name
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
  location            = data.azurerm_resource_group.mattermost_location.location

  address_space        = var.address_space
  aks_subnet_addresses = var.aks_subnet_addresses
  pod_subnet_addresses = var.pod_subnet_addresses

  environment   = var.environment
  email_contact = var.email_contact

  # Nat Gateway
  nat_gateway_enabled = true
  nat_gateway_name    = local.nat_gateway_name
  nat_public_ip_name  = local.nat_public_ip_name

  aks_subnet_name = var.aks_subnet_name
  pod_subnet_name = var.pod_subnet_name


  tags = merge({ name = "${local.base_identifier}-vnet" }, local.tags)
}
