

module "dns_record" {
  source = "../../../modules/azure/common/dns_record"

  email_contact       = var.email_contact
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  unique_name_prefix  = var.unique_name_prefix
  dns_zone_name       = var.mattermost_domain

  vnet_name = local.vnet_name

  # private_dns_zone_vnet_link_name = var.private_dns_zone_vnet_link_name
}
