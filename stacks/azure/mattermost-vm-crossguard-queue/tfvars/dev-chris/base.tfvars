# stacks/azure/mattermost-vm-crossguard/tfvars/dev-chris/base.tfvars

# General
email_contact       = "christopher.fickess@mattermost.com"
environment         = "dev-chris"
location            = "eastus2"
resource_group_name = "chrisfickess-tfstate-azk"
# Key Vault name = unique_name_prefix + "-kv" — must be ≤ 24 chars total.
# "mm-cg-dev-chris-kv" = 19 chars. Safe.
unique_name_prefix  = "mattermost-cg-dev"

# Networking
vnet_address_space = "10.10.0.0/16"
vm_a_subnet_cidr   = "10.10.1.0/24"
vm_b_subnet_cidr   = "10.10.2.0/24"

# VM
vm_size        = "Standard_B2s"
admin_username = "azureuser"
# Restrict this to your IP for any deployment that stays up longer than a few hours.
allowed_ssh_cidr = "0.0.0.0/0"

# Mattermost
mattermost_version = "11.6.0"

# CrossGuard Queue Storage
inbound_queue_name  = "crossguard-inbound"
outbound_queue_name = "crossguard-outbound"
blob_container_name = "crossguard-files"

# Key Vault readers — personal identities that can fetch SSH keys via az login.
# Find your object ID: az ad signed-in-user show --query id -o tsv
key_vault_reader_object_ids = {
  chris = "7ced9db5-d867-4820-9fd3-3c777df7c3c8"
}
