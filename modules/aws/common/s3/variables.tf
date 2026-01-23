
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

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
}

variable "bucket_policy_json" {
  description = "The JSON policy document to apply to the S3 bucket."
  type        = string
  default     = ""
}
