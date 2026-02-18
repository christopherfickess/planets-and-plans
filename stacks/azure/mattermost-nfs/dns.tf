


module "dns_record" {
  depends_on = [module.nfs]

  source = "../../../modules/azure/common/dns_record"

  email_contact       = var.email_contact
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  unique_name_prefix  = var.unique_name_prefix
  dns_zone_name       = var.private_dns_zone_name
  vnet_name           = local.vnet_name
}

# Create DNS A record pointing to the private endpoint IP
resource "azurerm_private_dns_a_record" "nfs_a_record" {
  depends_on = [
    module.nfs,
    module.dns_record
  ]

  name                = local.private_dns_a_record_name
  zone_name           = module.dns_record.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [module.nfs.nfs_pe_private_ip_address]
}
