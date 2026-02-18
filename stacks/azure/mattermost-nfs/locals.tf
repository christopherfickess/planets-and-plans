
locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "mattermost-${var.environment}"

  aks_name  = "${local.base_identifier}-aks"
  vnet_name = "${local.base_identifier}-vnet"


  # Dns and Private Endpoint names
  private_dns_zone_vnet_link_name = "${local.base_identifier}-dns-link"
  private_dns_a_record_name       = lower("${local.base_identifier_lower_case_only}nfs")
  private_endpoint_name           = "${local.base_identifier}-nfs-pe"
  storage_share_name              = "${local.base_identifier_lower_case_only}share"

  base_identifier_lower_case_only = "mattermost${var.environment_special}"

  # storage_account name
  storage_account_name = "${local.base_identifier_lower_case_only}store"

  # Nat Gateway and Public IP names
  nat_public_ip_name = "${local.base_identifier}-nat-pip"
  nat_gateway_name   = "${local.base_identifier}-nat"

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
