# To create the first time deployment
resource "time_static" "deployment_date" {}

output "current_time" {
  value = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
}
