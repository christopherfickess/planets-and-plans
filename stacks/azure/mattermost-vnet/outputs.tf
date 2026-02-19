

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

output "dns_record_variables" {
  value = {
    zone_name     = module.dns_record.zone_name
    zone_id       = module.dns_record.zone_id
    dns_link_name = module.dns_record.dns_link_name
    dns_link_id   = module.dns_record.dns_link_id
  }
}

output "view_dns_record" {
  value = <<-EOT
  az network private-dns zone list --resource-group ${var.resource_group_name}
  az network private-dns zone show --name ${var.mattermost_domain} --resource-group ${var.resource_group_name}
  az network private-dns record-set a list --zone-name ${var.mattermost_domain} --resource-group ${var.resource_group_name}
  az network private-dns zone-virtual-network-link list --resource-group ${var.resource_group_name}
  az network private-dns zone-virtual-network-link show --name ${module.dns_record.dns_link_name} --zone-name ${var.mattermost_domain} --resource-group ${var.resource_group_name}
  EOT
}

# -----------------------------------------------------------------------------
# Load Balancer Outputs - For Kubernetes annotations and AGIC
# -----------------------------------------------------------------------------
output "load_balancer_type" {
  value       = var.deploy_load_balancer ? var.lb_type : null
  description = "The load balancer type (nlb or alb)."
}

output "load_balancer_fqdn" {
  value       = var.deploy_load_balancer ? module.load_balancer[0].fqdn : null
  description = "Stable FQDN for CNAME. Create CNAME from your domain to this hostname."
}

output "load_balancer_resource_group" {
  value       = var.deploy_load_balancer ? module.load_balancer[0].resource_group_name : null
  description = "Resource group for azure-load-balancer-resource-group annotation."
}

output "nlb_pip_name" {
  value       = var.deploy_load_balancer && var.lb_type == "nlb" ? module.load_balancer[0].nlb_pip_name : null
  description = "Public IP name for service.beta.kubernetes.io/azure-pip-name annotation (NLB only)."
}

output "alb_id" {
  value       = var.deploy_load_balancer && var.lb_type == "alb" ? module.load_balancer[0].alb_id : null
  description = "Application Gateway ID for AGIC brownfield integration (ALB only)."
}

# -----------------------------------------------------------------------------
# Mattermost K8s LoadBalancer - Dedicated PIP with FQDN for CNAME (like AWS ELB)
# -----------------------------------------------------------------------------
output "mattermost_lb_pip_name" {
  value       = var.deploy_load_balancer ? module.load_balancer[0].mattermost_lb_pip_name : null
  description = "Public IP name for service.beta.kubernetes.io/azure-pip-name on Mattermost LoadBalancer service."
}

output "mattermost_lb_fqdn" {
  value       = var.deploy_load_balancer ? module.load_balancer[0].mattermost_lb_fqdn : null
  description = "Stable FQDN for CNAME. Create CNAME manually: dev-chris.dev.cloud.mattermost.com -> this."
}

output "mattermost_public_dns_nameservers" {
  value       = var.deploy_mattermost_public_dns && var.deploy_load_balancer ? module.dns_record.mattermost_public_zone_nameservers : null
  description = "Azure DNS nameservers. Add as NS records at parent zone (cloud.mattermost.com) to delegate dev.cloud.mattermost.com."
}
