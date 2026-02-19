# -----------------------------------------------------------------------------
# Load Balancer (NLB or ALB) - Deployed outside AKS for decoupled lifecycle
# -----------------------------------------------------------------------------
# Use outputs (nlb_pip_name, alb_fqdn, etc.) for Kubernetes service annotations
# or AGIC brownfield integration. See README for annotation examples and az CLI.
# -----------------------------------------------------------------------------

module "load_balancer" {
  depends_on = [module.mattermost_vnet]

  count  = var.deploy_load_balancer ? 1 : 0
  source = "../../../modules/azure/common/load_balancer"

  lb_type             = var.lb_type
  unique_name_prefix  = local.base_identifier
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
  location            = var.location
  vnet_name           = module.mattermost_vnet.vnet_name
  subnet_name         = var.lb_type == "alb" ? var.appgw_subnet_name : var.aks_subnet_name
  dns_label           = ""
  tags                = local.tags
}
