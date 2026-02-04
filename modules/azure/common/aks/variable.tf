# modules/azure/common/aks/variable.tf

# -------------------------------
# General / Environment Variables
# -------------------------------
variable "email_contact" {
  description = "Email contact for resource tagging."
  type        = string
}

variable "environment" {
  description = "Environment type (e.g., dev, prod)."
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment."
  type        = string
  # default     = "East US"
}

variable "module_version" {
  description = "Version of the module."
  type        = string
  default     = "11.0.0"
}

variable "resource_group_name" {
  description = "Name of the resource group for Terraform state."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

# -------------------------------
# Azure AD / Group Variables
# -------------------------------
# variable "azure_pde_admin_group_display_name" {
#   description = "Display name for the Azure PDE admin group."
#   type        = string
# }

variable "aks_admin_rbac_name" {
  description = "User or service principal UPN that should have cluster-admin binding inside AKS"
  type        = string
}

variable "admin_group_display_name" {
  description = "Display name for the Azure AD admin group."
  type        = string
}

variable "user_group_display_name" {
  description = "Display name for the Azure AD user group."
  type        = string
}

variable "rbac_aad_tenant_id" {
  description = "The Azure AD tenant ID for AKS RBAC."
  type        = string
}


# -------------------------------
# Networking / VNet Variables
# -------------------------------
variable "vnet_subnet" {
  type = object({
    id = string
  })
  # default = {
  #   id = "10.0.0.0/24"
  # }
}

variable "pod_subnet" {
  type = object({
    id = string
  })
  # default = {
  #   id = "10.0.1.0/24"
  # }
}

variable "network_plugin_mode" {
  description = "The network plugin mode for AKS cluster."
  type        = string
  default     = null
}

# -------------------------------
# AKS Cluster Core Variables
# -------------------------------

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.32.6"
}

variable "net_profile_service_cidr" {
  description = "The service CIDR for the AKS cluster."
  type        = string
}

variable "net_profile_dns_service_ip" {
  description = "The DNS service IP for the AKS cluster."
  type        = string
}

variable "private_cluster_enabled" {
  description = "Enable Private Cluster for the AKS cluster."
  type        = bool
}

# -------------------------------
# AKS Node Pool Variables
# -------------------------------

variable "system_node_pool" {
  description = "Configuration for the AKS system (default) node pool."
  type = object({
    name                 = string
    vm_size              = string
    node_count           = number
    auto_scaling_enabled = bool
    min_count            = number
    max_count            = number
    node_type            = string # "System" or "User"
    os_type              = string
    os_disk_size_gb      = number
    os_disk_type         = string
    availability_zones   = list(string)
    node_labels          = map(string)
  })
  default = {
    name                 = "system"
    vm_size              = "Standard_D2s_v5"
    node_count           = 2
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 5
    node_type            = "System"
    os_type              = "AzureLinux3"
    os_disk_size_gb      = 100
    os_disk_type         = "Managed"
    availability_zones   = ["1", "2", "3"]
    node_labels          = { nodepool = "system" }
  }
}

variable "node_pools" {
  type = map(object({
    name                 = string
    vm_size              = string
    mode                 = string
    node_count           = number
    auto_scaling_enabled = bool
    min_count            = number
    max_count            = number
    os_type              = string
    os_disk_size_gb      = number
    node_labels          = map(string)
  }))
  # default = {}
}
#   workloads = {
#     name                 = "workloads"
#     vm_size              = "Standard_D2s_v5"
#     mode                 = "User"
#     node_count           = 2
#     auto_scaling_enabled = true
#     min_count            = 2
#     max_count            = 6
#     os_type              = "AzureLinux3"
#     os_disk_size_gb      = 100
#     node_labels          = { role = "workloads" }
#   }
# }


# -------------------------------
# Azure Security / Identity Variables
# -------------------------------
variable "workload_identity_enabled" {
  description = "Enable Azure AD Workload Identity for AKS."
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer for the AKS cluster."
  type        = bool
  default     = false
}

# -------------------------------
# Other / Managed Resources
# -------------------------------
variable "firewall_rules" {
  description = "List of firewall rules for PostgreSQL server."
  type = list(object({
    name     = optional(string)
    start_ip = string
    end_ip   = string
  }))
  default = []
}

# -------------------------------
# End of Variables
# -------------------------------
