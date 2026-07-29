resource "aws_cloudwatch_log_group" "execution" {
  name              = "/aws-glue/jobs/${var.name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_glue_job" "dataset" {
  name     = var.name
  role_arn = aws_iam_role.execution.arn

  glue_version      = var.runtime.glue_version
  worker_type       = var.runtime.worker_type
  number_of_workers = var.runtime.workers
  timeout           = var.runtime.timeout

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.runtime_bucket}/${var.script_key}"
  }

  default_arguments = {
    "--TempDir"                          = local.temporary_directory
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.execution.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--input_database"                   = var.input_database
    "--input_dataset"                    = var.input_dataset
    "--output_database"                  = var.output_database
    "--output_dataset"                   = var.output_dataset
  }

  tags = var.tags
}
