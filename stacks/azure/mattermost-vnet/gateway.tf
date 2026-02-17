
locals {
  application_gateway_name                           = "${var.unique_name_prefix}-appgw"
  application_gateway_public_ip_name                 = "${var.unique_name_prefix}-appgw-pip"
  application_gateway_subnet_name                    = "${var.unique_name_prefix}-appgw-subnet"
  application_gateway_ip_configuration_name          = "${var.unique_name_prefix}-appgw-ip-config"
  application_gateway_frontend_ip_configuration_name = "${var.unique_name_prefix}-appgw-frontend-ip"
  application_gateway_backend_address_pool_name      = "${var.unique_name_prefix}-appgw-backend-pool"
  application_gateway_backend_http_settings_name     = "${var.unique_name_prefix}-appgw-backend-http-settings"
  application_gateway_http_listener_name             = "${var.unique_name_prefix}-appgw-http-listener"
  application_gateway_request_routing_rule_name      = "${var.unique_name_prefix}-appgw-routing-rule"
  application_gateway_subnet_address_prefixes        = ["10.0.10.0/24"]
  vnet_name                                          = module.vnet.vnet_name
}

module "gateway" {
  source = "../../modules/azure/common/gateway"
  count  = var.deploy_gateway ? 1 : 0

  # Common Variables
  module_version      = var.module_version
  unique_name_prefix  = var.unique_name_prefix
  environment         = var.environment
  email_contact       = var.email_contact
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name

  # Application Gateway Variables
  application_gateway_name                           = local.application_gateway_name
  application_gateway_public_ip_name                 = local.application_gateway_public_ip_name
  application_gateway_subnet_name                    = local.application_gateway_subnet_name
  application_gateway_ip_configuration_name          = local.application_gateway_ip_configuration_name
  application_gateway_frontend_ip_configuration_name = local.application_gateway_frontend_ip_configuration_name
  application_gateway_backend_address_pool_name      = local.application_gateway_backend_address_pool_name
  application_gateway_backend_http_settings_name     = local.application_gateway_backend_http_settings_name
  application_gateway_http_listener_name             = local.application_gateway_http_listener_name
  application_gateway_request_routing_rule_name      = local.application_gateway_request_routing_rule_name
  application_gateway_subnet_address_prefixes        = local.application_gateway_subnet_address_prefixes
  vnet_name                                          = local.vnet_name
}
