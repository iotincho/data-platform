output "job_name" {
  description = "Name of the dataset transformation job."
  value       = aws_glue_job.dataset.name
}

output "job_arn" {
  description = "ARN of the dataset transformation job."
  value       = aws_glue_job.dataset.arn
}

output "role_arn" {
  description = "ARN of the role used by the transformation execution environment."
  value       = aws_iam_role.execution.arn
}
