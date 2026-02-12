
resource "time_static" "deployment_date" {
  triggers = {
    always_run = "true" # optional, to force creation only once
  }
}
