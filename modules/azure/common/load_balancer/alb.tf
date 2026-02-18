# -----------------------------------------------------------------------------
# ALB - Azure Application Gateway (L7)
# -----------------------------------------------------------------------------
# Equivalent to AWS ALB. Use for HTTP/HTTPS, path-based routing, SSL termination.
# Requires a dedicated subnet (no other resources in the same subnet).
# -----------------------------------------------------------------------------

locals {
  dns_label_alb = var.dns_label != "" ? var.dns_label : replace(lower("${var.unique_name_prefix}-alb"), "/[^a-z0-9-]/", "-")
}

resource "azurerm_public_ip" "alb_pip" {
  count = lower(var.lb_type) == "alb" ? 1 : 0

  name                = "${var.unique_name_prefix}-alb-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = local.dns_label_alb

  tags = merge(var.tags, { Name = "${var.unique_name_prefix}-alb-pip" })
}

resource "azurerm_application_gateway" "alb" {
  count = lower(var.lb_type) == "alb" ? 1 : 0

  name                = "${var.unique_name_prefix}-alb"
  resource_group_name = var.resource_group_name
  location             = var.location
  enable_http2        = true

  sku {
    name     = var.alb_sku_name
    tier     = var.alb_sku_tier
    capacity = var.alb_capacity
  }

  gateway_ip_configuration {
    name      = "${var.unique_name_prefix}-alb-gateway-ip"
    subnet_id = data.azurerm_subnet.lb_subnet.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${var.unique_name_prefix}-alb-frontend"
    public_ip_address_id = azurerm_public_ip.alb_pip[0].id
  }

  # Placeholder backend - template for later use
  backend_address_pool {
    name = "${var.unique_name_prefix}-alb-pool"
  }

  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity  = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  # Default HTTP listener - redirect or route as needed
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name  = "${var.unique_name_prefix}-alb-frontend"
    frontend_port_name              = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "${var.unique_name_prefix}-alb-pool"
    backend_http_settings_name = "default-http-settings"
    priority                   = 100
  }

  tags = merge(var.tags, { Name = "${var.unique_name_prefix}-alb" })
}
