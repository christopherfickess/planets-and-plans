# stacks/azure/mattermost-vnet/tfvars/dev-chris/base.tfvars

# General / Environment Variables
email_contact       = "christopher.fickess@mattermost.com"
environment         = "dev-chris"
location            = "East US 2"
resource_group_name = "chrisfickess-tfstate-azk"
unique_name_prefix  = "mattermost-dev"

aks_admin_rbac_name          = "aks-admin"
deploy_mattermost_public_dns = true
mattermost_domain            = "dev-chris.dev.cloud.mattermost.com"
mattermost_dns_zone_name     = "dev.cloud.mattermost.com"
mattermost_dns_record_name   = "dev-chris"

azure_primary_group_display_name = "Azure PDE"

# Networking Variables
address_space = ["172.16.12.0/23"]

aks_subnet_name      = "aks-subnet"
aks_subnet_addresses = ["172.16.12.0/24"]

bastion_subnet_name      = "AzureBastionSubnet"
bastion_subnet_addresses = ["172.16.13.0/26"]

db_subnet_name      = "db-subnet"
db_subnet_addresses = ["172.16.13.64/27"]

jumpbox_subnet_name      = "jumpbox-subnet"
jumpbox_subnet_addresses = ["172.16.13.96/28"]

appgw_subnet_name      = "appgw-subnet"
appgw_subnet_addresses = ["172.16.13.128/28"]
