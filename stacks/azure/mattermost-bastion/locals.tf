# stacks/azure/mattermost-bastion/locals.tf

locals {
  aks_cluster_name = "${var.unique_name_prefix}-aks"
  vnet_name        = "${var.unique_name_prefix}-vnet"

  tags = {
    Date           = time_static.deployment_date.rfc3339
    Email          = var.email_contact
    Env            = var.environment
    Resource_Group = var.resource_group_name
    Type           = "Bastion Host"
    Deployment     = "Terraform"
  }
}
