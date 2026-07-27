locals {
  results_bucket_name = "${var.resource_name_prefix}-athena-${var.workgroup_name}-results"
  results_bucket_uri  = "s3://${local.results_bucket_name}"

  resource_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    Workgroup   = var.workgroup_name
  })
}
