# stacks/azure/mattermost-azk/tfvars/dev-chris/backend.hcl

resource_group_name  = "chrisfickess-tfstate-azk"
storage_account_name = "tfstatechrisfickess"
container_name       = "azure-bastion-tfstate"
key                  = "env/dev/mattermost-bastion/terraform.tfstate"
use_azuread_auth     = true

