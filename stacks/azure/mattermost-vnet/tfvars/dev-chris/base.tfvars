# stacks/azure/mattermost-vnet/tfvars/dev-chris/base.tfvars

# General / Environment Variables
email_contact       = "christopher.fickess@mattermost.com"
environment         = "dev-chris"
location            = "East US 2"
resource_group_name = "chrisfickess-tfstate-azk"
unique_name_prefix  = "mattermost-dev"

aks_admin_rbac_name = "aks-admin"

deploy_mattermost_public_dns = true
mattermost_dns_zone_name     = "dev.cloud.mattermost.com"
mattermost_dns_record_name   = "dev-chris"
