

###############################################
# S3 Buckets
###############################################
resource "aws_s3_bucket" "mattermost_bucket" {
  bucket = var.s3_bucket_name

  tags = merge(
    { Name = local.s3_bucket_name },
    local.tags
  )
}

resource "aws_s3_bucket_policy" "mattermost_s3_bucket_policy" {
  depends_on = [aws_s3_bucket.mattermost_bucket]
  bucket     = aws_s3_bucket.mattermost_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.mattermost_ec2_role.name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.mattermost_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.mattermost_ec2_role.name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.mattermost_bucket.arn]
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {

  bucket = aws_s3_bucket.mattermost_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.mattermost_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket                  = aws_s3_bucket.mattermost_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.mattermost_bucket.id

  rule {
    id     = "Expire old versions"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket        = aws_s3_bucket.mattermost_bucket.id
  target_bucket = aws_s3_bucket.mattermost_bucket.id
  target_prefix = "log/"
}
