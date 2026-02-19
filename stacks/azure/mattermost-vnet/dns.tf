# -----------------------------------------------------------------------------
# DNS - Private zone (VNet) + optional public zone + CNAME for Mattermost
# -----------------------------------------------------------------------------
# Private zone: for internal resolution (dns_zone_name).
# Public zone + CNAME: when deploy_mattermost_public_dns = true. Creates
# dev.cloud.mattermost.com zone and dev-chris CNAME -> LB FQDN.
# CNAME is manual if you use Cloudflare or another DNS provider.
# -----------------------------------------------------------------------------

module "dns_record" {
  depends_on = [module.mattermost_vnet, module.load_balancer]

  source = "../../../modules/azure/common/dns_record"

  email_contact       = var.email_contact
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  unique_name_prefix  = var.unique_name_prefix
  dns_zone_name       = var.mattermost_domain
  vnet_name           = module.mattermost_vnet.vnet_name

  # Optional: public zone + CNAME for Mattermost (dev-chris -> LB FQDN)
  create_public_mattermost_cname  = var.deploy_mattermost_public_dns && var.deploy_load_balancer
  public_mattermost_zone_name     = var.mattermost_dns_zone_name
  public_mattermost_cname_name     = var.mattermost_dns_record_name
  public_mattermost_cname_target   = var.deploy_load_balancer ? module.load_balancer[0].mattermost_lb_fqdn : ""
}
