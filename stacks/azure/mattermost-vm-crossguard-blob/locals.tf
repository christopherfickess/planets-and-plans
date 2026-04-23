# stacks/azure/mattermost-vm-crossguard-blob/locals.tf

resource "time_static" "deployment_date" {}

locals {
  tags = {
    Date           = time_static.deployment_date.rfc3339
    Email          = var.email_contact
    Env            = var.environment
    Resource_Group = var.resource_group_name
    Type           = "Mattermost CrossGuard Blob VM"
    Deployment     = "Terraform"
  }
}
