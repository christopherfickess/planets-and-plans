# stacks/azure/mattermost-aks/tfvars/dev-chris/base.tfvars

# General / Environment Variables
email_contact       = "christopher.fickess@mattermost.com"
environment         = "dev-chris"
location            = "eastus"
resource_group_name = "chrisfickess-tfstate-azk"
unique_name_prefix  = "mattermost-dev"

# Azure AD / Group Variables
azure_pde_admin_group_display_name = "Azure PDE"
aks_admin_rbac_name                = "aks-admin"

# Networking / Virtual Network Variables
# These should match your existing VNet configuration
# address_space        = ["172.16.12.0/23"]
# aks_subnet_name      = "aks-subnet"
# aks_subnet_addresses = ["172.16.12.0/24"]

# AKS Cluster Core Variables
# Match existing cluster values to prevent replacement
net_profile_service_cidr   = "10.2.0.0/16"
net_profile_dns_service_ip = "10.2.0.10"

# Enable private cluster - API server only accessible from within VNet
# Requires bastion host for access
private_cluster_enabled = true

# AKS Node Pool Variables (using defaults if not specified)
# system_node_pool = {
#   name                 = "system"
#   vm_size              = "Standard_DS2_v2"
#   node_count           = 3
#   auto_scaling_enabled = true
#   min_count            = 3
#   max_count            = 10
#   node_type            = "System"
#   os_type              = "AzureLinux3"
#   os_disk_size_gb      = 100
#   os_disk_type         = "Managed"
#   availability_zones   = []
#   node_labels          = { nodepool = "system" }
# }

# node_pools = {}

# Azure Security / Identity Variables
workload_identity_enabled = true
oidc_issuer_enabled       = true

# Other Variables
bad_naming_convention = "chrisfickess-azk-dev" # Will be removed
firewall_rules        = []
