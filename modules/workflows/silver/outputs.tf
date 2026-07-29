output "runtime_bucket_name" {
  description = "Name of the bucket that stores Silver workflow scripts and temporary execution data."
  value       = aws_s3_bucket.runtime.bucket
}

output "runtime_bucket_arn" {
  description = "ARN of the bucket that stores Silver workflow scripts and temporary execution data."
  value       = aws_s3_bucket.runtime.arn
}

output "dataset_job_names" {
  description = "Dataset transformation job names keyed by output dataset."
  value = {
    orders = module.orders.job_name
  }
}

output "dataset_job_arns" {
  description = "Dataset transformation job ARNs keyed by output dataset."
  value = {
    orders = module.orders.job_arn
  }
}
