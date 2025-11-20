
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


data "aws_ami" "ami_type" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["${var.ami_type}"]
  }
}

# S3 Policy for EC2 Access to bucket
data "aws_iam_policy_document" "mattermost_s3_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.mattermost_bucket.arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.mattermost_bucket.arn}/*"]
    effect    = "Allow"
  }
}

# Assume EC2 Role Trust Relationship
data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# RDS Policy for EC2 to Access the Database
data "aws_iam_policy_document" "mattermost_rds_policy" {
  statement {
    actions = [
      "rds-db:connect",
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = [
      # RDS DB user ARN format: arn:aws:rds-db:region:account-id:dbuser:dbi-resource-id/db-username
      "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.mattermost_rds.resource_id}/${aws_db_instance.mattermost_rds.username}",
      aws_ssm_parameter.mattermost_db_username.arn,
      aws_ssm_parameter.mattermost_db_password.arn
    ]

    effect = "Allow"
  }
}
