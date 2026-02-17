

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

output "gateway_variables" {
  value = {
    id                        = module.gateway.application_gateway.id
    name                      = module.gateway.application_gateway.name
    location                  = module.gateway.application_gateway.location
    frontend_ip_configuration = module.gateway.application_gateway.frontend_ip_configuration
    frontend_port             = module.gateway.application_gateway.frontend_port
    backend_address_pool      = module.gateway.application_gateway.backend_address_pool
    backend_http_settings     = module.gateway.application_gateway.backend_http_settings
    http_listener             = module.gateway.application_gateway.http_listener
    request_routing_rule      = module.gateway.application_gateway.request_routing_rule
    subnet_address_prefixes   = module.gateway.application_gateway.subnet_address_prefixes
  }
}
