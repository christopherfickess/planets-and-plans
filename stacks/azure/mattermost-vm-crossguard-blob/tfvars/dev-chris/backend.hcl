# stacks/azure/mattermost-vm-crossguard-blob/tfvars/dev-chris/backend.hcl

resource_group_name  = "chrisfickess-tfstate-azk"
storage_account_name = "tfstatechrisfickess"
container_name       = "azure-crossguard-tfstate"
key                  = "env/dev/mattermost-vm-crossguard-blob/terraform.tfstate"
use_azuread_auth     = true
