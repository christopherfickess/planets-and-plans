
locals {
  date          = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  vnet_name     = "${var.unique_name_prefix}-vnet"
  keyvault_name = "${var.unique_name_prefix}-kv"

  # Service Account names for workload identity
  # Must match uami_name from the mattermost-aks stack service_accounts
  external_secrets_uami_name = "${var.unique_name_prefix}-external-secrets-identity"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
