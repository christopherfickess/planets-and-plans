# stacks/azure/mattermost-azk/variable.tf

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

variable "resource_group_name" {
  description = "Name of the resource group for Terraform state."
  type        = string
}

variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

# -------------------------------
# Azure AD / Group Variables
# -------------------------------
variable "azure_group_principal_id" {
  description = "The Object ID of the Azure AD group for Mattermost admins."
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


# -------------------------------
# Networking / Virtual Network Variables
# -------------------------------
variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
}

variable "address_space" {
  description = "The address space that is used by the Virtual Network."
  type        = list(string)
  # ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_addresses" {
  description = "The address prefixes for the AKS subnet."
  type        = list(string)
  # ["10.0.0.0/24"]
}

variable "pod_subnet_name" {
  description = "The name of the Pod subnet."
  type        = string
  default     = "pods-subnet"
}

variable "pod_subnet_addresses" {
  description = "The address prefixes for the Pod subnet."
  type        = list(string)
  # ["10.0.1.0/24"]
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

# Changes access to the cluster API endpoint (bastion required if true)
variable "private_cluster_enabled" {
  description = "Enable Private Cluster for the AKS cluster."
  type        = bool
  default     = false
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
    vm_size              = "Standard_DS2_v2"
    node_count           = 3
    auto_scaling_enabled = true
    min_count            = 3
    max_count            = 10
    node_type            = "System"
    os_type              = "AzureLinux3"
    os_disk_size_gb      = 100
    os_disk_type         = "Managed"
    availability_zones   = []
    node_labels          = { nodepool = "system" }
  }
}

variable "node_pools" {
  description = "List of additional node pools for the AKS cluster."
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
  # default = {
  #     workloads = {
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
  default = {}
}

# -------------------------------
# Azure Security / Identity Variables
# -------------------------------
variable "workload_identity_enabled" {
  description = "Enable Azure AD Workload Identity for AKS."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer for the AKS cluster."
  type        = bool
  default     = true
}

# -------------------------------
# Other Managed / AZK Resources Variables
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
# End of Azure Mattermost AZK Variables
# -------------------------------
