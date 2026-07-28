output "analytics_workgroup_name" {
  description = "Name of the Analytics query workgroup."
  value       = module.analytics_workgroup.workgroup_name
}

output "analytics_results_bucket_name" {
  description = "Name of the S3 bucket that stores Analytics query results."
  value       = module.analytics_workgroup.results_bucket_name
}

output "analytics_results_bucket_arn" {
  description = "ARN of the S3 bucket that stores Analytics query results."
  value       = module.analytics_workgroup.results_bucket_arn
}

output "analytics_results_bucket_uri" {
  description = "S3 URI of the bucket that stores Analytics query results."
  value       = module.analytics_workgroup.results_bucket_uri
}
