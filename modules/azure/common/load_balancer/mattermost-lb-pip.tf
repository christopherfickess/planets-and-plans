# -----------------------------------------------------------------------------
# Dedicated Public IP for Mattermost Kubernetes LoadBalancer service
# -----------------------------------------------------------------------------
# The load_balancer module's PIP is attached to NLB/ALB. This standalone PIP
# is for the K8s LoadBalancer service (azure-pip-name annotation). It has a
# stable FQDN for CNAME - like AWS ELB dns_name. Create CNAME in Cloudflare:
#   dev-chris.dev.cloud.mattermost.com -> mattermost-{env}-mattermost.{region}.cloudapp.azure.com
# -----------------------------------------------------------------------------

locals {
  mattermost_lb_dns_label = replace(lower("${var.unique_name_prefix}-mattermost"), "/[^a-z0-9-]/", "-")
}

resource "azurerm_public_ip" "mattermost_lb" {
  name                = "${var.unique_name_prefix}-mattermost-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = local.mattermost_lb_dns_label

  tags = merge(var.tags, { Name = "${var.unique_name_prefix}-mattermost-pip" })
}
