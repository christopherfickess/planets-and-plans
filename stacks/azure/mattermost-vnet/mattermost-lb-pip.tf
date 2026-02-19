# -----------------------------------------------------------------------------
# Dedicated Public IP for Mattermost Kubernetes LoadBalancer service
# -----------------------------------------------------------------------------
# The load_balancer module's PIP is attached to NLB/ALB. This standalone PIP
# is for the K8s LoadBalancer service (azure-pip-name annotation). It has a
# stable FQDN for CNAME - like AWS ELB dns_name. Create CNAME in Cloudflare:
#   dev-chris.dev.cloud.mattermost.com -> mattermost-{env}-mattermost.{region}.cloudapp.azure.com
# -----------------------------------------------------------------------------

locals {
  mattermost_lb_dns_label = replace(lower("${local.base_identifier}-mattermost"), "/[^a-z0-9-]/", "-")
}

resource "azurerm_public_ip" "mattermost_lb" {
  count = var.deploy_load_balancer ? 1 : 0

  name                = "${local.base_identifier}-mattermost-pip"
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = local.mattermost_lb_dns_label

  tags = merge(local.tags, { Name = "${local.base_identifier}-mattermost-pip" })
}
