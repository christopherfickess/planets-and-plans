

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

resource "aws_s3_bucket_policy" "mattermost_s3_policy" {
  depends_on = [
    data.aws_iam_policy_document.mattermost_s3_policy,
    aws_s3_bucket.mattermost_bucket
  ]

  bucket = aws_s3_bucket.mattermost_bucket.id
  policy = data.aws_iam_policy_document.mattermost_s3_policy.json
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
