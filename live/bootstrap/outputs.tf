output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state files."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket that stores Terraform state files."
  value       = aws_s3_bucket.terraform_state.arn
}
