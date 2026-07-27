locals {
  layer_bucket_name = "${var.resource_name_prefix}-${var.layer_name}"

  resource_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    Layer       = var.layer_name
  })

  datasets = {
    for dataset_key, dataset in var.datasets :
    dataset_key => jsondecode(file(dataset.schema_file))
  }

  storage_formats = {
    csv = {
      classification        = "csv"
      input_format          = "org.apache.hadoop.mapred.TextInputFormat"
      output_format         = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      serialization_parameters = {
        separatorChar = ","
        quoteChar     = "\""
        escapeChar    = "\\"
      }
    }
    parquet = {
      classification           = "parquet"
      input_format             = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
      output_format            = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
      serialization_library    = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      serialization_parameters = {}
    }
  }
}
