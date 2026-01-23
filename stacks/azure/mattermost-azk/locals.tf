locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "${var.unique_name_suffix}-mattermost-${local.date}"

  tags = {
    type  = "Testing"
    email = var.email_contact
    date  = time_static.deployment_date.rfc3339
  }
}
