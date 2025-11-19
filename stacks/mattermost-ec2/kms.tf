

###############################################
# KMS Key
###############################################
resource "aws_kms_key" "ec2_kms" {
  description             = "KMS key for EC2 root volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "ec2_kms_alias" {
  name          = "alias/ec2-root-key"
  target_key_id = aws_kms_key.ec2_kms.key_id
}

resource "aws_kms_key_policy" "ec2_kms_key_policy" {
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
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${local.ec2_iam_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_access}"
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
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_access}",
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
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_access}",
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


