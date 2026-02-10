
# provider "kubernetes" {
#   host                   = module.aks.admin_host
#   client_certificate     = base64decode(module.aks.admin_client_certificate)
#   client_key             = base64decode(module.aks.admin_client_key)
#   cluster_ca_certificate = base64decode(module.aks.admin_cluster_ca_certificate)
# }
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.33.0"
    }
  }
}
