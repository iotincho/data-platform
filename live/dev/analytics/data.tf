data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_bucket_name
    key    = "dev/foundation/terraform.tfstate"
    region = var.aws_region
  }
}
