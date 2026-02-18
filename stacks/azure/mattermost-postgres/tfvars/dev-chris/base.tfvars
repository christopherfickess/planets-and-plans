# stacks/azure/mattermost-postgres/tfvars/dev-chris/base.tfvars

# General / Environment Variables
email_contact       = "christopher.fickess@mattermost.com"
environment         = "dev-chris"
location            = "East US 2"
resource_group_name = "chrisfickess-tfstate-azk"
unique_name_prefix  = "mattermost-dev"

# Networking Variables
aks_subnet_name = "aks-subnet"
db_subnet_name  = "db-subnet"

# Database Variables
