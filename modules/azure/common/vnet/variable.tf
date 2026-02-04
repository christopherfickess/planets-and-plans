# modules/azure/common/vnet/variable.tf

# -------------------------------
# General Variables
# -------------------------------
variable "module_version" {
  description = "Version of the module."
  type        = string
  default     = "11.0.0"
}

variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment type (e.g., dev, prod)."
  type        = string
}

variable "email_contact" {
  description = "Email contact for resource tagging."
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment."
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the resource group for Terraform state."
  type        = string
}

# -------------------------------
# Azure VNet Variables
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

variable "subnet_configs" {
  description = "List of subnets to create"
  type = map(object({
    name                = string
    address_prefixes    = list(string)
    nat_gateway_enabled = bool
    nat_gateway_id      = string
  }))
}

# -------------------------------
# Nat Gateway Variables
# -------------------------------
variable "nat_gateway_enabled" {
  description = "Enable NAT Gateway for the VNet."
  type        = bool
  default     = true
}

variable "nat_public_ip_name" {
  description = "The name of the Public IP for the NAT Gateway."
  type        = string
}

variable "nat_gateway_name" {
  description = "The name of the NAT Gateway."
  type        = string
}


# -------------------------------
# End of Azure VNet Variables
# -------------------------------
