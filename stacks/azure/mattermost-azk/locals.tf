
locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "${var.environment}-mattermost-${local.date}"

  nat_public_ip_name = "${local.base_identifier}-nat-pip"
  nat_gateway_name   = "${local.base_identifier}-nat"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
