# -----------------------------------------------------------------------------
# Dedicated Public IP for Mattermost Kubernetes LoadBalancer service
# -----------------------------------------------------------------------------
# Mattermost now routes through AGIC (Application Gateway Ingress Controller).
# The dedicated PIP is no longer needed — the App Gateway provisioned by the
# AKS AGIC add-on provides the single shared IP for all ingress traffic.
# Update DNS CNAME after terraform apply on mattermost-aks:
#   dev-chris.dev.cloud.mattermost.com -> <app-gateway-fqdn>
# -----------------------------------------------------------------------------

# Previous (dedicated LoadBalancer PIP — replaced by AGIC):
# locals {
#   mattermost_lb_dns_label = replace(lower("${var.unique_name_prefix}-mattermost"), "/[^a-z0-9-]/", "-")
# }
# resource "azurerm_public_ip" "mattermost_lb" {
#   name                = "${var.unique_name_prefix}-mattermost-pip"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   domain_name_label   = local.mattermost_lb_dns_label
#   tags = merge(var.tags, { Name = "${var.unique_name_prefix}-mattermost-pip" })
# }
