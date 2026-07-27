resource "aws_s3_bucket" "query_results" {
  bucket = local.results_bucket_name
  tags   = local.resource_tags
}

resource "aws_s3_bucket_versioning" "query_results" {
  bucket = aws_s3_bucket.query_results.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "query_results" {
  bucket = aws_s3_bucket.query_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "query_results" {
  bucket = aws_s3_bucket.query_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_athena_workgroup" "query" {
  name  = var.workgroup_name
  state = "ENABLED"
  tags  = local.resource_tags

  configuration {
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "${local.results_bucket_uri}/"
    }
  }
}
