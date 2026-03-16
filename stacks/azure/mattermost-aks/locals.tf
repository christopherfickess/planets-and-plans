
locals {
  date      = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  vnet_name = "${var.unique_name_prefix}-vnet"

  # TODO: switch to new naming convention when bad_naming_convention is removed
  # admin_group_display_name = "mattermost-aks-${var.environment}-admins"
  # user_group_display_name  = "mattermost-aks-${var.environment}-users"
  admin_group_display_name = "${var.bad_naming_convention}-admins"
  user_group_display_name  = "${var.bad_naming_convention}-users"

  # service account for workload identity
  service_account_names = {
    external-secrets = {
      namespace = "external-secrets"
      uami_name = "${var.unique_name_prefix}-external-secrets-identity"
    }
    db-secrets = {
      namespace = "secrets"
      uami_name = "${var.unique_name_prefix}-db-secrets-identity"
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
