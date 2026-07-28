module "analytics_workgroup" {
  source = "../../../modules/workgroup"

  project_name         = data.terraform_remote_state.foundation.outputs.project_name
  environment          = data.terraform_remote_state.foundation.outputs.environment
  resource_name_prefix = data.terraform_remote_state.foundation.outputs.resource_name_prefix
  common_tags          = data.terraform_remote_state.foundation.outputs.common_tags
  workgroup_name       = local.analytics_workgroup_name
}
