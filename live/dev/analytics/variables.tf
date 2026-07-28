variable "aws_region" {
  description = "AWS region where Analytics query environments are deployed."
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "Name of the Bootstrap-provisioned S3 bucket that stores Terraform state."
  type        = string
}
