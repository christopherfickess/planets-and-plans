# stacks/azure/mattermost-vm-crossguard-blob/tfvars/dev-chris/base.tfvars

# General
email_contact       = "christopher.fickess@mattermost.com"
environment         = "dev-chris"
location            = "eastus2"
resource_group_name = "chrisfickess-tfstate-azk"
# Key Vault names = unique_name_prefix + "-a-kv" and "-b-kv"
# "mm-cg-b-dev" (10) + "-a-kv" (5) = 15 chars — well under the 24-char limit.
unique_name_prefix  = "mattermost-crossguard-blob-dev"

# Networking — use a different VNet CIDR than the queue stack (10.10.0.0/16)
# to avoid address space conflicts if both stacks ever peer or share a hub.
vnet_address_space = "10.20.0.0/16"
vm_a_subnet_cidr   = "10.20.1.0/24"
vm_b_subnet_cidr   = "10.20.2.0/24"

# VMs — same size and version for both instances
vm_size            = "Standard_B2s"
admin_username     = "azureuser"
# Restrict this to your IP for any deployment that stays up longer than a few hours.
allowed_ssh_cidr   = "0.0.0.0/0"
mattermost_version = "10.5"

# CrossGuard Blob Storage
blob_container_name = "crossguard-files"

# Key Vault readers — personal identities that can fetch SSH keys via az login.
# Find your object ID: az ad signed-in-user show --query id -o tsv
key_vault_reader_object_ids = {
  chris = "7ced9db5-d867-4820-9fd3-3c777df7c3c8"
}
