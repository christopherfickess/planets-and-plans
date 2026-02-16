
variable "bad_naming_convention" {
  description = "Will be removed"
  type        = string
  default     = "chrisfickess-azk-dev"
}

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

variable "environment_special" {
  description = "Special environment identifier for unique naming."
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
# VNet / Networking Variables
# -------------------------------

variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}


# -------------------------------
# DNS / Private Endpoint Variables
# -------------------------------

variable "private_dns_zone_name" {
  description = "Name of the private DNS zone."
  type        = string
  default     = "privatelink.file.core.windows.net"
}
