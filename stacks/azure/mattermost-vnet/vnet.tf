# stacks/azure/mattermost-azk/vnet.tf


module "mattermost_vnet" {
  source = "../../../modules/azure/common/vnet"

  unique_name_prefix = local.base_identifier

  vnet_name           = local.vnet_name
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
  location            = data.azurerm_resource_group.mattermost_location.location

  address_space = var.address_space

  environment   = var.environment
  email_contact = var.email_contact

  # Nat Gateway
  nat_gateway_enabled = true
  nat_gateway_name    = local.nat_gateway_name
  nat_public_ip_name  = local.nat_public_ip_name

  subnet_configs = {
    "aks-subnet" = {
      name                = var.aks_subnet_name
      address_prefixes    = var.aks_subnet_addresses
      nat_gateway_enabled = true
      nat_gateway_id      = module.mattermost_vnet.nat_gateway_id
    }
    "db-subnet" = {
      name                = var.db_subnet_name
      address_prefixes    = var.db_subnet_addresses
      nat_gateway_enabled = false
      nat_gateway_id      = ""
    }
    # Make a second subnet for pods if needed
    # "pods-subnet" = {
    #   name                = var.pod_subnet_name
    #   address_prefixes    = var.pod_subnet_addresses
    #   nat_gateway_enabled = false
    #   nat_gateway_id      = ""
    # }
  }


  tags = merge({ name = "${local.base_identifier}-vnet" }, local.tags)
}
