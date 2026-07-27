locals {
  schemas_root = "${path.root}/../../../docs/datasets/schemas"

  bronze_datasets = {
    orders = {
      schema_file = "${local.schemas_root}/bronze/orders.json"
    }
  }

  silver_datasets = {
    orders = {
      schema_file = "${local.schemas_root}/silver/orders.json"
    }
  }
}
