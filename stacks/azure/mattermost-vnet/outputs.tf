

output "vnet_variables" {
  value = {
    address_spaces = module.mattermost_vnet.address_spaces
    vnet_name      = module.mattermost_vnet.vnet_name
    vnet_id        = module.mattermost_vnet.vnet_id
    peerings       = module.mattermost_vnet.peerings
    resource       = module.mattermost_vnet.resource
    subnets        = module.mattermost_vnet.subnets
    # aks_subnet_id    = module.mattermost_vnet.aks_subnet_id
    nat_gateway_id   = module.mattermost_vnet.nat_gateway_id
    nat_public_ip_id = module.mattermost_vnet.nat_public_ip_id
  }
}
