module "orders" {
  source = "../commons/dataset_job"

  name           = local.orders_job.name
  runtime_bucket = aws_s3_bucket.runtime.bucket
  script_key     = local.orders_job.script_key

  input_database      = var.bronze_database_name
  input_dataset       = local.orders_job.input_dataset
  input_data_location = "s3://${var.bronze_bucket_name}/${local.orders_job.input_dataset}/"

  output_database      = var.silver_database_name
  output_dataset       = local.orders_job.output_dataset
  output_data_location = "s3://${var.silver_bucket_name}/${local.orders_job.output_dataset}/"

  runtime = local.orders_job.runtime
  tags    = local.resource_tags
}
