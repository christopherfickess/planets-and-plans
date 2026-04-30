# stacks/azure/mattermost-vm-crossguard-servicebus/tfvars/dev-chris/base.tfvars

# General
email_contact       = "christopher.fickess@mattermost.com"
environment         = "dev-chris"
location            = "eastus2"
resource_group_name = "chrisfickess-tfstate-azk"
# Key Vault name = unique_name_prefix + "-a-kv" / "-b-kv" — must be ≤ 24 chars total.
# "mattermost-cg-dev-a-kv" = 23 chars. Safe.
unique_name_prefix = "mattermost-cg-dev"

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

# CrossGuard Service Bus
service_bus_sku           = "Standard"
service_bus_capacity      = 0
inbound_queue_name        = "crossguard-inbound"
outbound_queue_name       = "crossguard-outbound"
lock_duration             = "PT1M"
max_delivery_count        = 10
default_message_ttl       = "P14D"
# max_message_size_in_kilobytes only applies when service_bus_sku = "Premium"
max_message_size_in_kilobytes = 256

# CrossGuard Blob Storage
blob_container_name = "crossguard-files"

# Key Vault readers — personal identities that can fetch SSH keys via az login.
# Find your object ID: az ad signed-in-user show --query id -o tsv
key_vault_reader_object_ids = {
  chris = "7ced9db5-d867-4820-9fd3-3c777df7c3c8"
}
