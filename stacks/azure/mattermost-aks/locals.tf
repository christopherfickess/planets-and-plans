
locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "mattermost-${var.environment}"

  nat_public_ip_name = "${local.base_identifier}-nat-pip"
  nat_gateway_name   = "${local.base_identifier}-nat"
  vnet_name          = "${local.base_identifier}-vnet"

  # Figure out how to deploy this group
  admin_group_display_name = "${var.bad_naming_convention}-admins"
  user_group_display_name  = "${var.bad_naming_convention}-users"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
