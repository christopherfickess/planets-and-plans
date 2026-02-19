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
variable "aks_admin_rbac_name" {
  description = "User or service principal UPN that should have cluster-admin binding inside AKS"
  type        = string
  default     = "aks-admin"
}

# -------------------------------
# Networking / Virtual Network Variables
# -------------------------------
variable "address_space" {
  description = "The address space that is used by the Virtual Network."
  type        = list(string)
  default     = ["172.16.12.0/23"]
}

variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_addresses" {
  description = "The address prefixes for the AKS subnet."
  type        = list(string)
  default     = ["172.16.12.0/24"]
}

variable "bastion_subnet_name" {
  description = "The name of the bastion subnet."
  type        = string
  default     = "AzureBastionSubnet"
}

variable "bastion_subnet_addresses" {
  description = "The address prefixes for the bastion subnet."
  type        = list(string)
  default     = ["172.16.13.0/26"]
}

variable "db_subnet_name" {
  description = "The name of the database subnet."
  type        = string
  default     = "db-subnet"
}

variable "db_subnet_addresses" {
  description = "The address prefixes for the database subnet."
  type        = list(string)
  default     = ["172.16.13.64/27"]
}

variable "jumpbox_subnet_name" {
  description = "The name of the jumpbox subnet."
  type        = string
  default     = "jumpbox-subnet"
}

variable "jumpbox_subnet_addresses" {
  description = "The address prefixes for the jumpbox subnet."
  type        = list(string)
  default     = ["172.16.13.96/28"]
}

variable "appgw_subnet_name" {
  description = "The name of the Application Gateway subnet (dedicated, no other resources)."
  type        = string
  default     = "appgw-subnet"
}

variable "appgw_subnet_addresses" {
  description = "The address prefixes for the Application Gateway subnet (min /26)."
  type        = list(string)
  default     = ["172.16.13.128/28"]
}

# -------------------------------
# Load Balancer Variables
# -------------------------------
variable "deploy_load_balancer" {
  description = "Whether to deploy the load balancer (NLB or ALB) in the VNet stack."
  type        = bool
  default     = true
}

variable "lb_type" {
  description = "Load balancer type: 'nlb' (Standard LB, L4) or 'alb' (Application Gateway, L7)."
  type        = string
  default     = "alb"
}

# -------------------------------
# DNS Variables
# -------------------------------
variable "private_dns_zone_name" {
  description = "The name of the private DNS zone."
  type        = string
  default     = "privatelink.postgres.database.azure.com"
}

variable "deploy_gateway" {
  description = "Whether to deploy a NAT Gateway for outbound connectivity (required for private AKS clusters)."
  type        = bool
  default     = false
}

# -------------------------------
# DNS / Private Endpoint Variables
# -------------------------------
variable "mattermost_domain" {
  description = "Custom domain for Mattermost deployment."
  type        = string
  default     = "dev-chris.dev.cloud.mattermost.com"
}

variable "private_dns_zone_vnet_link_name" {
  description = "Name for the private DNS zone VNet link."
  type        = string
  default     = "nfs-dns-vnet-link"
}


# -------------------------------
# Key Vault Variables
# -------------------------------
variable "azure_primary_group_display_name" {
  description = "Display name of the Azure AD group to grant access to the Key Vault."
  type        = string
  default     = "Azure PDE"
}

# -------------------------------
# End of Azure Mattermost AZK Variables
# -------------------------------
