# Azure storage account used to store this stack's Terraform state file.
# This must be a storage account that already exists — Terraform will not create it.
# Run `terraform init -backend-config=backend.hcl` to initialize with these values.

# Resource group containing the state storage account.
resource_group_name = "<your-tfstate-resource-group>"

# Storage account that holds the state container.
storage_account_name = "<your-tfstate-storage-account>"

# Blob container inside the storage account where state files are stored.
container_name = "tfstate"

# Path to the state file within the container. Use a unique key per stack+environment.
key = "crossguard-send-to-queue/terraform.tfstate"

# Use Azure AD auth to access the state storage account instead of a storage key.
# Requires your Azure identity to have Storage Blob Data Contributor on the account.
use_azuread_auth = true
