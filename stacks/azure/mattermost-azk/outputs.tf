
# Module Outputs for VNet
# output "vnet_id" {
#   value = module.mattermost_vnet.vnet_name
# }

# output "subnets" {
#   value = module.avm-res-network-virtualnetwork.subnets
# }

output "aks_module" {
  value     = module.mattermost_aks
  sensitive = true
}

output "vnet_module" {
  value     = module.mattermost_vnet
  sensitive = true
}

# Output AKS Variables
output "aks_variables" {
  value = {
    cluster_name = module.mattermost_aks.aks_name
    location     = module.mattermost_aks.location
  }
}
