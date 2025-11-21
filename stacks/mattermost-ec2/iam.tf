###############################################
# IAM Role + Policy
###############################################
resource "aws_iam_role" "mattermost_ec2_role" {
  name               = local.ec2_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
  tags = merge(
    { Name = local.ec2_iam_role_name },
    local.tags
  )
}

# EC2 Instance Policy
resource "aws_iam_policy" "mattermost_ec2_policy" {
  depends_on = [data.aws_iam_policy_document.mattermost_ec2_s3_policy]

  name        = local.ec2_iam_role_policy_name
  description = "IAM policy to allow Mattermost EC2 instances to access Mattermost S3 bucket"
  policy      = data.aws_iam_policy_document.mattermost_ec2_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  depends_on = [
    aws_iam_role.mattermost_ec2_role,
    aws_iam_policy.mattermost_ec2_policy
  ]

  role       = aws_iam_role.mattermost_ec2_role.name
  policy_arn = aws_iam_policy.mattermost_ec2_policy.arn
}

# RDS Policy Process
resource "aws_iam_policy" "mattermost_rds_policy" {
  depends_on  = [data.aws_iam_policy_document.mattermost_rds_policy]
  name        = local.rds_db_policy_name
  description = "Allow Mattermost EC2 instance (and admins) to connect to RDS using IAM authentication"
  policy      = data.aws_iam_policy_document.mattermost_rds_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_mattermost_rds_policy" {
  depends_on = [aws_iam_role.mattermost_ec2_role, aws_iam_policy.mattermost_rds_policy]
  role       = aws_iam_role.mattermost_ec2_role.name
  policy_arn = aws_iam_policy.mattermost_rds_policy.arn
}
