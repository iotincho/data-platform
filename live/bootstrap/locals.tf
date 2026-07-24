locals {
  terraform_state_bucket_name = "${var.project_name}-${var.environment}-tfstate"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
