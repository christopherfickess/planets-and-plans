# stacks/azure/mattermost-vm-crossguard-queue/locals.tf

resource "time_static" "deployment_date" {}

locals {
  tags = {
    Date           = time_static.deployment_date.rfc3339
    Email          = var.email_contact
    Env            = var.environment
    Resource_Group = var.resource_group_name
    Type           = "Mattermost CrossGuard VM"
    Deployment     = "Terraform"
  }
}
