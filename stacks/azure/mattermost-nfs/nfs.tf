module "nfs" {
  source = "../../../modules/azure/common/nfs"

  email_contact                    = var.email_contact
  environment                      = var.environment
  location                         = var.location
  resource_group_name              = var.resource_group_name
  tags                             = local.tags
  unique_name_prefix               = var.unique_name_prefix
  azure_primary_group_display_name = var.azure_primary_group_display_name
  subnet_name                      = var.aks_subnet_name
  vnet_name                        = local.vnet_name
}
