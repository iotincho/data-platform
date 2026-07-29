module "bronze_layer" {
  source = "../../../modules/data_layer"

  project_name         = data.terraform_remote_state.foundation.outputs.project_name
  environment          = data.terraform_remote_state.foundation.outputs.environment
  common_tags          = data.terraform_remote_state.foundation.outputs.common_tags
  resource_name_prefix = data.terraform_remote_state.foundation.outputs.resource_name_prefix
  layer_name           = "bronze"
  datasets             = local.bronze_datasets
}

module "silver_layer" {
  source = "../../../modules/data_layer"

  project_name         = data.terraform_remote_state.foundation.outputs.project_name
  environment          = data.terraform_remote_state.foundation.outputs.environment
  common_tags          = data.terraform_remote_state.foundation.outputs.common_tags
  resource_name_prefix = data.terraform_remote_state.foundation.outputs.resource_name_prefix
  layer_name           = "silver"
  datasets             = local.silver_datasets
}

module "silver" {
  source = "../../../modules/workflows/silver"

  resource_name_prefix = data.terraform_remote_state.foundation.outputs.resource_name_prefix
  bronze_bucket_name   = module.bronze_layer.bucket_name
  bronze_database_name = module.bronze_layer.database_name
  silver_bucket_name   = module.silver_layer.bucket_name
  silver_database_name = module.silver_layer.database_name
  common_tags          = data.terraform_remote_state.foundation.outputs.common_tags
}
