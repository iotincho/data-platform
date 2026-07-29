locals {
  runtime_bucket_name = "${var.resource_name_prefix}-silver-runtime"

  resource_tags = merge(var.common_tags, {
    Layer    = "silver"
    Workflow = "silver"
  })

  orders_job = {
    name           = "silver-orders"
    script_key     = "silver/orders.py"
    input_dataset  = "orders_raw"
    output_dataset = "orders"
    runtime = {
      glue_version = "5.0"
      worker_type  = "G.1X"
      workers      = 2
      timeout      = 10
    }
  }
}
