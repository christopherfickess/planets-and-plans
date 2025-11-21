resource "aws_ssm_parameter" "mattermost_db_username" {
  name  = "${var.parameter_store_path_prefix}/db_username"
  type  = "SecureString"
  value = var.mattermost_db_username

  tags = merge(
    { Name = "${var.parameter_store_path_prefix}/db_username" },
    local.tags
  )
}

resource "aws_ssm_parameter" "mattermost_db_password" {
  name  = "${var.parameter_store_path_prefix}/db_password"
  type  = "SecureString"
  value = var.mattermost_db_password

  tags = merge(
    { Name = "${var.parameter_store_path_prefix}/db_password" },
    local.tags
  )
}
