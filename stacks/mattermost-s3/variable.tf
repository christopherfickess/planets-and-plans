
variable "unique_name_suffix" {
  description = "Unique suffix for resource naming."
  type        = string
}

##############################################
#                 S3 / Storage               #
##############################################
variable "s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "ec2-mattermost-bucket"
}

variable "s3_bucket_policy_name" {
  description = "Name of the S3 bucket policy."
  type        = string
  default     = "mattermost-s3-bucket-policy"
}

variable "account_role_name" {
  description = "AWS primary role that needs access to deployed resources."
  type        = string
}
