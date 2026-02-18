
locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "mattermost-${var.environment}"

  base_identifier_lower_case_only = "mattermost${var.environment_special}"

  storage_account_name = "${local.base_identifier_lower_case_only}store"
  storage_share_name   = "${local.base_identifier_lower_case_only}share"

  nat_public_ip_name = "${local.base_identifier}-nat-pip"
  nat_gateway_name   = "${local.base_identifier}-nat"
  vnet_name          = "${local.base_identifier}-vnet"

  # Figure out how to deploy this group
  admin_group_display_name = "${var.bad_naming_convention}-admins"
  user_group_display_name  = "${var.bad_naming_convention}-users"


  # service account for workload identity
  # service_account_names = [] # Defaults to none
  service_account_names = {
    external-secrets = {
      namespace = "external-secrets"
      uami_name = "${local.base_identifier}-external-secrets-identity"
    }
    db-secrets = {
      namespace = "secrets"
      uami_name = "${local.base_identifier}-db-secrets-identity"
    }
  }

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
