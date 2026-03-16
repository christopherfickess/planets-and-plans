
locals {
  date      = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  vnet_name = "${var.unique_name_prefix}-vnet"

  # DNS A record name must match storage account name (alphanumeric, no hyphens)
  private_dns_a_record_name = lower(replace(var.unique_name_prefix, "/[^a-z0-9]/", "")) + "nfs"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
