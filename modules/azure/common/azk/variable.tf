# -------------------------------
# General Variables
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
# Azure Group Variables
# -------------------------------
variable "admin_group_display_name" {
  description = "Display name for the Azure AD admin group."
  type        = string
}

variable "user_group_display_name" {
  description = "Display name for the Azure AD user group."
  type        = string
}



# -------------------------------
# AZK Resources Variables
# -------------------------------
variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.32.6"
}

variable "pod_subnets" {
  description = "The pod subnet ID for the AKS cluster."
  type        = list(string)
}

variable "vnet_subnets" {
  description = "The subnet ID for the AKS cluster."
  type        = list(string)
}

# -------------------------------
# AKS Node Pool Variables
# -------------------------------
variable "node_pools" {
  description = "List of additional node pools for the AKS cluster."
  type = list(object({
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
  # default = [{
  #   workloads = {
  #     name                 = "workloads"
  #     vm_size              = "Standard_D8s_v5"
  #     mode                 = "User"
  #     auto_scaling_enabled = true
  #     min_count            = 2
  #     max_count            = 6
  #     os_type              = "Linux"
  #     os_disk_size_gb      = 100
  #     node_labels = {
  #       role = "workloads"
  #     }
  #   }
  # }]
}

# -------------------------------
# Networking and Security Variables
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

variable "net_profile_service_cidr" {
  description = "The service CIDR for the AKS cluster."
  type        = string
}

variable "net_profile_dns_service_ip" {
  description = "The DNS service IP for the AKS cluster."
  type        = string
}

variable "admin_group_object_ids" {
  description = "List of AAD group object IDs for AKS admin access."
  type        = list(string)
  # default     = ["00000000-0000-0000-0000-000000000000"]
}

# -------------------------------
# End of AZK Resources Variables
# -------------------------------
