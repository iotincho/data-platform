# Bootstrap must retain local state because it creates the bucket used by the
# remote backends of the remaining root modules.
terraform {
  backend "local" {}
}
