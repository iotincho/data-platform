resource "aws_s3_bucket" "runtime" {
  bucket = local.runtime_bucket_name
  tags   = local.resource_tags
}

resource "aws_s3_bucket_versioning" "runtime" {
  bucket = aws_s3_bucket.runtime.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "runtime" {
  bucket = aws_s3_bucket.runtime.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "runtime" {
  bucket = aws_s3_bucket.runtime.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
