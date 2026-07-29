output "bronze_bucket_name" {
  description = "Name of the Bronze layer bucket."
  value       = module.bronze_layer.bucket_name
}

output "bronze_bucket_arn" {
  description = "ARN of the Bronze layer bucket."
  value       = module.bronze_layer.bucket_arn
}

output "bronze_bucket_uri" {
  description = "S3 URI of the Bronze layer bucket."
  value       = "s3://${module.bronze_layer.bucket_name}"
}

output "bronze_database_name" {
  description = "Glue Catalog database name for the Bronze layer."
  value       = module.bronze_layer.database_name
}

output "bronze_table_names" {
  description = "Glue Catalog table names for the Bronze layer, keyed by dataset."
  value       = module.bronze_layer.dataset_table_names
}

output "silver_bucket_name" {
  description = "Name of the Silver layer bucket."
  value       = module.silver_layer.bucket_name
}

output "silver_bucket_arn" {
  description = "ARN of the Silver layer bucket."
  value       = module.silver_layer.bucket_arn
}

output "silver_bucket_uri" {
  description = "S3 URI of the Silver layer bucket."
  value       = "s3://${module.silver_layer.bucket_name}"
}

output "silver_database_name" {
  description = "Glue Catalog database name for the Silver layer."
  value       = module.silver_layer.database_name
}

output "silver_table_names" {
  description = "Glue Catalog table names for the Silver layer, keyed by dataset."
  value       = module.silver_layer.dataset_table_names
}

output "silver_dataset_job_names" {
  description = "Silver dataset transformation job names keyed by output dataset."
  value       = module.silver.dataset_job_names
}
