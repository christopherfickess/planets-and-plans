

output "aks_variables" {
  value = {
    cluster_name           = module.mattermost_aks.name
    resource_group_name    = module.mattermost_aks.resource_group_name
    location               = module.mattermost_aks.location
    dns_prefix             = module.mattermost_aks.dns_prefix
    default_node_pool_name = module.mattermost_aks.default_node_pool_name
    node_count             = module.mattermost_aks.node_count
    vm_size                = module.mattermost_aks.vm_size
  }
}
