module "s3_bucket" {
  source = "../../modules/common/s3"

  s3_bucket_name        = local.s3_bucket_name
  s3_bucket_policy_name = local.s3_bucket_policy_name
  tags                  = local.tags
  bucket_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "s3:*",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${module.s3_bucket.s3_bucket_arn}/*",
          "${module.s3_bucket.s3_bucket_arn}"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action   = ["s3:ListBucket"]
        Resource = [module.s3_bucket.s3_bucket_arn]
      }
    ]
  }) # Add your bucket policy JSON here if needed

}
