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
# Networking / Virtual Network Variables
# -------------------------------
variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}

variable "db_subnet_name" {
  description = "The name of the database subnet."
  type        = string
  default     = "db-subnet"
}

variable "database_names" {
  description = "List of database names to create on the PostgreSQL server. Example: [\"my_db1\", \"my_db2\"]"
  type        = list(string)
  default     = ["mattermost"]
}

variable "server_version" {
  description = "The version of the PostgreSQL server."
  type        = string
  default     = "11"
}

# variable "vnet_rules" {
#   description = "List of VNet rules to apply to the PostgreSQL server."
#   type = list(object({
#     name      = string
#     subnet_id = string
#   }))
#   # default = []
#   # { name = "subnet1", subnet_id = "<subnet_id>" }
# }

# -------------------------------
# Storage Size Variable
# -------------------------------
variable "storage_mb" {
  description = "The storage size in MB for the PostgreSQL server."
  type        = number
  default     = 5120
}

variable "sku_name" {
  description = "The SKU name for the PostgreSQL server."
  type        = string
  default     = "B_Gen5_1"
}

# -------------------------------
# End of Azure Mattermost AZK Variables
# -------------------------------
