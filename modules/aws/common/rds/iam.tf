
resource "aws_iam_role" "mattermost_rds_role" {
  name               = var.mattermost_rds_role_name
  assume_role_policy = var.assume_role_policy_json

  tags = merge(
    { Name = var.mattermost_rds_role_name },
    var.tags
  )
}

resource "aws_iam_policy" "mattermost_rds_policy" {
  name        = var.rds_db_policy_name
  description = "Allow Mattermost EC2 instance (and admins) to connect to RDS using IAM authentication"
  policy      = var.mattermost_rds_policy_json

  tags = merge(
    { Name = var.rds_db_policy_name },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "attach_mattermost_rds_policy" {
  depends_on = [aws_iam_role.mattermost_rds_role, aws_iam_policy.mattermost_rds_policy]
  role       = aws_iam_role.mattermost_rds_role.name
  policy_arn = aws_iam_policy.mattermost_rds_policy.arn
}
