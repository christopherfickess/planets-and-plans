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
# Azure PostgreSQL Variables
# -------------------------------
variable "server_name" {
  description = "The name of the PostgreSQL server."
  type        = string
}

variable "administrator_login" {
  description = "The administrator login for the PostgreSQL server."
  type        = string
}

variable "administrator_password" {
  description = "The administrator password for the PostgreSQL server."
  type        = string
  sensitive   = true
}

variable "server_version" {
  description = "The version of the PostgreSQL server."
  type        = string
  default     = "11"
}

variable "database_names" {
  description = "List of database names to create on the PostgreSQL server. Example: [\"my_db1\", \"my_db2\"]"
  type        = list(string)
}

variable "firewall_rules" {
  description = "List of firewall rules to apply to the PostgreSQL server."
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  # default     = []
  # [
  #   { name = var.firewall_name, start_ip = "10.0.0.5", end_ip = "10.0.0.8" },
  #   { start_ip = "127.0.0.0", end_ip = "127.0.1.0" },
  # ]
}

variable "vnet_rules" {
  description = "List of VNet rules to apply to the PostgreSQL server."
  type = list(object({
    name      = string
    subnet_id = string
  }))
  # default = []
  # { name = "subnet1", subnet_id = "<subnet_id>" }
}

# -------------------------------
# End of Azure PostgreSQL Variables
# -------------------------------
