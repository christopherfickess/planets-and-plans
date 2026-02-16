
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

variable "availability_zone" {
  description = "The availability zone to deploy the PostgreSQL server in (e.g., 1, 2, 3)."
  type        = string
  default     = "2"
}

# -------------------------------
# Azure PostgreSQL Variables
# -------------------------------
variable "high_availability" {
  type = object({
    mode                      = string # either "ZoneRedundant" or "SameZone"
    standby_availability_zone = string # optional, required if mode is SameZone
  })
  default = {
    mode                      = "Disabled"
    standby_availability_zone = ""
  }

  # default = null
}

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
  # default     = "11"
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

# --------------------------------
# Storage and SKU Variables
# --------------------------------

variable "storage_mb" {
  description = "The storage size in MB for the PostgreSQL server."
  type        = number
  # default     = 5120
}

variable "sku_name" {
  description = "The SKU name for the PostgreSQL server."
  type        = string
  # default     = "B_Gen5_1"
}


# -------------------------------
# End of Azure PostgreSQL Variables
# -------------------------------

variable "backup_retention_days" {
  description = "Number of days to retain automated backups."
  type        = number
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo redundant backup replication across regions."
  type        = bool
}

variable "delegated_subnet_id" {
  description = "ID of the subnet delegated to Microsoft.DBforPostgreSQL/flexibleServers."
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone used for internal name resolution."
  type        = string
}

variable "db_collation" {
  description = "Database collation for sorting and comparison rules."
  type        = string
}

variable "db_charset" {
  description = "Character set encoding for the databases."
  type        = string
}


variable "public_network_access_enabled" {
  description = "Enable or disable public network access to the PostgreSQL server."
  type        = bool
  default     = false
}
