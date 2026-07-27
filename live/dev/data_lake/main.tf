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
