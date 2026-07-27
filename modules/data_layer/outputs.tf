output "bucket_name" {
  description = "Name of the S3 bucket that stores this Data Lake layer."
  value       = aws_s3_bucket.layer.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket that stores this Data Lake layer."
  value       = aws_s3_bucket.layer.arn
}

output "database_name" {
  description = "Name of the Glue Catalog database for this Data Lake layer."
  value       = aws_glue_catalog_database.layer.name
}

output "dataset_table_names" {
  description = "Glue Catalog table names keyed by dataset name."
  value = {
    for dataset_key, table in aws_glue_catalog_table.dataset :
    dataset_key => table.name
  }
}
