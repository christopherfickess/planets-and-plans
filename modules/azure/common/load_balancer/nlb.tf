# -----------------------------------------------------------------------------
# NLB - Azure Standard Load Balancer (L4)
# -----------------------------------------------------------------------------
# Equivalent to AWS NLB. Use for TCP/UDP load balancing.
# TLS termination typically done at application (e.g. Envoy Gateway).
# -----------------------------------------------------------------------------

locals {
  lb_suffix     = lower(var.lb_type) == "nlb" ? "nlb" : "alb"
  lb_name       = "${var.unique_name_prefix}-${local.lb_suffix}"
  # DNS label: lowercase alphanumeric + hyphens, 3-63 chars. Used for stable FQDN (CNAME target).
  dns_label_nlb = var.dns_label != "" ? var.dns_label : replace(lower("${var.unique_name_prefix}-nlb"), "/[^a-z0-9-]/", "-")
}

resource "azurerm_public_ip" "nlb_pip" {
  count = lower(var.lb_type) == "nlb" ? 1 : 0

  name                = "${local.lb_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.nlb_allocation_method
  sku                 = var.nlb_sku
  domain_name_label   = local.dns_label_nlb

  tags = merge(var.tags, { Name = "${local.lb_name}-pip" })
}

resource "azurerm_lb" "nlb" {
  count = lower(var.lb_type) == "nlb" ? 1 : 0

  name                = local.lb_name
  resource_group_name = var.resource_group_name
  location             = var.location
  sku                  = var.nlb_sku

  frontend_ip_configuration {
    name                 = "${local.lb_name}-frontend"
    public_ip_address_id = azurerm_public_ip.nlb_pip[0].id
  }

  tags = merge(var.tags, { Name = local.lb_name })
}

# Placeholder backend pool - template for later use with AKS/NodePort
# In practice, AKS manages its own LoadBalancer services; this module
# can be used to pre-create a static PIP for use via azure-pip-name annotation
resource "azurerm_lb_backend_address_pool" "nlb_pool" {
  count = lower(var.lb_type) == "nlb" ? 1 : 0

  name            = "${local.lb_name}-pool"
  loadbalancer_id = azurerm_lb.nlb[0].id
}
