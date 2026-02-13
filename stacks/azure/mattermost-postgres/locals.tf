
locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "mattermost-${var.environment}"

  keyvault_name = "${local.base_identifier}-pgs"

  # Postgres Variables
  database_names = ["${local.base_identifier}-db"]
  server_name    = "${local.base_identifier}-postgres"
  vnet_name      = "${local.base_identifier}-vnet"

  private_dns_zone_virtual_network_link_name = "${local.base_identifier}-postgres-link"


  # Create method for this password securely
  # administrator_password = "P@ssw0rd1234!"

  # VNet Variables
  aks_subnet_name = var.aks_subnet_name
  db_subnet_name  = var.db_subnet_name

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "AKS Cluster Testing"
    Deployment     = "Terraform"
  }
}
