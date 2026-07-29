locals {
  iam_arn_prefix = "arn:${data.aws_partition.current.partition}"

  runtime_bucket_arn = "${local.iam_arn_prefix}:s3:::${var.runtime_bucket}"
  script_arn         = "${local.runtime_bucket_arn}/${var.script_key}"

  input_location_parts  = split("/", trimprefix(trimsuffix(var.input_data_location, "/"), "s3://"))
  output_location_parts = split("/", trimprefix(trimsuffix(var.output_data_location, "/"), "s3://"))

  input_bucket_name  = local.input_location_parts[0]
  output_bucket_name = local.output_location_parts[0]
  input_data_prefix  = "${join("/", slice(local.input_location_parts, 1, length(local.input_location_parts)))}/*"
  output_data_prefix = "${join("/", slice(local.output_location_parts, 1, length(local.output_location_parts)))}/*"

  input_bucket_arn  = "${local.iam_arn_prefix}:s3:::${local.input_bucket_name}"
  output_bucket_arn = "${local.iam_arn_prefix}:s3:::${local.output_bucket_name}"
  input_data_arn    = "${local.input_bucket_arn}/${local.input_data_prefix}"
  output_data_arn   = "${local.output_bucket_arn}/${local.output_data_prefix}"

  temporary_data_prefix = "temporary/${var.name}/*"
  temporary_data_arn    = "${local.runtime_bucket_arn}/${local.temporary_data_prefix}"
  temporary_directory   = "s3://${var.runtime_bucket}/temporary/${var.name}/"

  glue_arn_prefix     = "${local.iam_arn_prefix}:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
  glue_catalog_arn    = "${local.glue_arn_prefix}:catalog"
  input_database_arn  = "${local.glue_arn_prefix}:database/${var.input_database}"
  input_table_arn     = "${local.glue_arn_prefix}:table/${var.input_database}/${var.input_dataset}"
  output_database_arn = "${local.glue_arn_prefix}:database/${var.output_database}"
  output_table_arn    = "${local.glue_arn_prefix}:table/${var.output_database}/${var.output_dataset}"
}
