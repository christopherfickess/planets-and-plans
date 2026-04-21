# stacks/azure/mattermost-vm-crossguard-queue/tfvars/dev-chris/backend.hcl

resource_group_name  = "chrisfickess-tfstate-azk"
storage_account_name = "tfstatechrisfickess"
container_name       = "azure-crossguard-tfstate"
key                  = "env/dev/mattermost-vm-crossguard-queue/terraform.tfstate"
use_azuread_auth     = true
