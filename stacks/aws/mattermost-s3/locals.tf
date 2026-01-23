locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "${var.unique_name_suffix}-mattermost-${local.date}"

  s3_bucket_name        = "${var.s3_bucket_name}-${local.base_identifier}"
  s3_bucket_policy_name = "${var.s3_bucket_policy_name}-${local.base_identifier}"

  tags = {
    Type = "Testing"
    Date = time_static.deployment_date.rfc3339
  }
}
