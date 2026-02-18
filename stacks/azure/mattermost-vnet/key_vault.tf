
module "mattermost_key_vault" {
  source = "../../../modules/azure/common/key_vault"

  unique_name_prefix = local.base_identifier

  resource_group_name              = var.resource_group_name
  location                         = var.location
  environment                      = var.environment
  email_contact                    = var.email_contact
  azure_primary_group_display_name = var.azure_primary_group_display_name
  tags                             = local.tags
}

