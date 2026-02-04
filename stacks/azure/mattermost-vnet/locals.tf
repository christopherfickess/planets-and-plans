
locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "mattermost-${var.environment}"

  nat_public_ip_name       = "${local.base_identifier}-nat-pip"
  nat_gateway_name         = "${local.base_identifier}-nat"
  admin_group_display_name = "${local.base_identifier}-admin-group"
  user_group_display_name  = "${local.base_identifier}-user-group"
  vnet_name                = "${local.base_identifier}-vnet"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
