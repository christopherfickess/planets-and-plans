# -----------------------------------------------------------------------------
# Load Balancer Module - Azure NLB (Standard LB) or ALB (Application Gateway)
# -----------------------------------------------------------------------------
# lb_type: "nlb" = Azure Standard Load Balancer (L4, like AWS NLB)
# lb_type: "alb" = Azure Application Gateway (L7, like AWS ALB)
# -----------------------------------------------------------------------------

variable "lb_type" {
  description = "Load balancer type: 'nlb' (Standard LB, L4) or 'alb' (Application Gateway, L7)."
  type        = string
  validation {
    condition     = contains(["nlb", "alb"], lower(var.lb_type))
    error_message = "lb_type must be 'nlb' or 'alb'."
  }
}

variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for deployment."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet"
}

variable "subnet_name" {
  description = "Name of the subnet for the load balancer. For ALB, use a dedicated subnet (e.g. appgw-subnet)."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# DNS - Stable FQDN for CNAME (like AWS ELB hostname)
# -----------------------------------------------------------------------------
variable "dns_label" {
  description = "DNS label for the Public IP. Creates stable FQDN: {label}.{region}.cloudapp.azure.com. Use for CNAME. If empty, derived from unique_name_prefix + lb suffix (e.g. mattermost-dev-chris-nlb)."
  type        = string
}

# -----------------------------------------------------------------------------
# NLB-specific (Standard Load Balancer)
# -----------------------------------------------------------------------------
variable "nlb_sku" {
  description = "SKU for Standard Load Balancer. Use 'Standard' for production."
  type        = string
  default     = "Standard"
}

variable "nlb_allocation_method" {
  description = "Public IP allocation method: Static or Dynamic."
  type        = string
  default     = "Static"
}

# -----------------------------------------------------------------------------
# ALB-specific (Application Gateway)
# -----------------------------------------------------------------------------
variable "alb_sku_name" {
  description = "Application Gateway SKU: Standard_v2, WAF_v2."
  type        = string
  default     = "Standard_v2"
}

variable "alb_sku_tier" {
  description = "Application Gateway tier: Standard_v2 or WAF_v2."
  type        = string
  default     = "Standard_v2"
}

variable "alb_capacity" {
  description = "Application Gateway capacity (autoscale min instances)."
  type        = number
  default     = 1
}
