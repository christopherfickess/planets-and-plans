

###############################################
# KMS Key
###############################################

resource "aws_kms_key" "ec2_kms" {
  description             = "KMS key for EC2 root volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = merge(
    { Name = local.ec2_iam_role_name },
    local.tags
  )
}

resource "aws_kms_alias" "ec2_kms_alias" {
  name          = local.kms_mattermost_kms_key_alias
  target_key_id = aws_kms_key.ec2_kms.key_id
}

resource "aws_kms_key_policy" "ec2_kms_key_policy" {
  depends_on = [aws_iam_role.mattermost_ec2_role]

  key_id = aws_kms_key.ec2_kms.key_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.ec2_iam_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}"
          ]

        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.ec2_iam_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow attachment of persistent resources"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.ec2_iam_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      }
    ]
  })
}


