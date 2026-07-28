# The state bucket and AWS region are supplied with -backend-config during
# terraform init because backend blocks cannot reference Terraform variables.
terraform {
  backend "s3" {
    key = "dev/analytics/terraform.tfstate"
  }
}
