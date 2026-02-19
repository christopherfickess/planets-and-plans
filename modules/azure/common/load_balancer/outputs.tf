# -----------------------------------------------------------------------------
# Outputs - values for Kubernetes service annotations (envoy-gateway, etc.)
# -----------------------------------------------------------------------------

output "lb_type" {
  value       = lower(var.lb_type)
  description = "The load balancer type (nlb or alb)."
}

output "fqdn" {
  value       = lower(var.lb_type) == "nlb" ? azurerm_public_ip.nlb_pip[0].fqdn : azurerm_public_ip.alb_pip[0].fqdn
  description = "Stable FQDN for CNAME. Create CNAME from your domain (e.g. dev-chris.dev.cloud.mattermost.com) to this hostname."
}

output "resource_group_name" {
  value       = var.resource_group_name
  description = "Resource group name for azure-load-balancer-resource-group annotation."
}

# -----------------------------------------------------------------------------
# NLB outputs
# -----------------------------------------------------------------------------
output "nlb_public_ip" {
  value       = lower(var.lb_type) == "nlb" ? azurerm_public_ip.nlb_pip[0].ip_address : null
  description = "Public IP address of the NLB (Standard Load Balancer)."
}

output "nlb_pip_name" {
  value       = lower(var.lb_type) == "nlb" ? azurerm_public_ip.nlb_pip[0].name : null
  description = "Public IP name for service.beta.kubernetes.io/azure-pip-name annotation."
}

output "nlb_fqdn" {
  value       = lower(var.lb_type) == "nlb" ? azurerm_public_ip.nlb_pip[0].fqdn : null
  description = "Stable FQDN for CNAME (e.g. mattermost-dev-chris-nlb.eastus2.cloudapp.azure.com). Create CNAME from your domain to this."
}

output "nlb_id" {
  value       = lower(var.lb_type) == "nlb" ? azurerm_lb.nlb[0].id : null
  description = "ID of the Standard Load Balancer."
}

# -----------------------------------------------------------------------------
# ALB outputs
# -----------------------------------------------------------------------------
output "alb_public_ip" {
  value       = lower(var.lb_type) == "alb" ? azurerm_public_ip.alb_pip[0].ip_address : null
  description = "Public IP address of the Application Gateway."
}

output "alb_fqdn" {
  value       = lower(var.lb_type) == "alb" ? azurerm_public_ip.alb_pip[0].fqdn : null
  description = "Stable FQDN for CNAME (e.g. mattermost-dev-chris-alb.eastus2.cloudapp.azure.com). Create CNAME from your domain to this."
}

output "alb_id" {
  value       = lower(var.lb_type) == "alb" ? azurerm_application_gateway.alb[0].id : null
  description = "ID of the Application Gateway."
}

output "alb_backend_address_pool_name" {
  value       = lower(var.lb_type) == "alb" ? one([for p in azurerm_application_gateway.alb[0].backend_address_pool : p.name]) : null
  description = "Backend address pool name for AKS AGIC integration."
}

# -----------------------------------------------------------------------------
# Mattermost K8s LoadBalancer - Dedicated PIP with FQDN for CNAME (like AWS ELB)
# -----------------------------------------------------------------------------
output "mattermost_lb_pip_name" {
  value       = azurerm_public_ip.mattermost_lb.name
  description = "Public IP name for service.beta.kubernetes.io/azure-pip-name on Mattermost LoadBalancer service."
}

output "mattermost_lb_fqdn" {
  value       = azurerm_public_ip.mattermost_lb.fqdn
  description = "Stable FQDN for CNAME. Point dev-chris.dev.cloud.mattermost.com to this in Cloudflare."
}
