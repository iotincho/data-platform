output "workgroup_name" {
  description = "Name of the Athena query workgroup."
  value       = aws_athena_workgroup.query.name
}

output "results_bucket_name" {
  description = "Name of the S3 bucket that stores Athena query results."
  value       = aws_s3_bucket.query_results.bucket
}

output "results_bucket_arn" {
  description = "ARN of the S3 bucket that stores Athena query results."
  value       = aws_s3_bucket.query_results.arn
}

output "results_bucket_uri" {
  description = "S3 URI of the bucket that stores Athena query results."
  value       = local.results_bucket_uri
}
