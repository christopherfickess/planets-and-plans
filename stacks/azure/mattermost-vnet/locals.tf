
locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "mattermost-${var.environment}"

  nat_public_ip_name = "${local.base_identifier}-nat-pip"
  nat_gateway_name   = "${local.base_identifier}-nat"
  vnet_name          = "${local.base_identifier}-vnet"

  private_dns_zone_virtual_network_link_name = "${local.base_identifier}-postgres-link"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
