resource "aws_s3_bucket" "layer" {
  bucket = local.layer_bucket_name
  tags   = local.resource_tags
}

resource "aws_s3_bucket_versioning" "layer" {
  bucket = aws_s3_bucket.layer.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "layer" {
  bucket = aws_s3_bucket.layer.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "layer" {
  bucket = aws_s3_bucket.layer.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_glue_catalog_database" "layer" {
  name        = var.layer_name
  description = "Glue Catalog database for the ${var.layer_name} Data Lake layer."
}

resource "aws_glue_catalog_table" "dataset" {
  for_each = local.datasets

  database_name = aws_glue_catalog_database.layer.name
  name          = each.value.dataset
  description   = each.value.description
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = local.storage_formats[each.value.format].classification
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.layer.bucket}/${each.value.dataset}/"
    input_format  = local.storage_formats[each.value.format].input_format
    output_format = local.storage_formats[each.value.format].output_format

    ser_de_info {
      serialization_library = local.storage_formats[each.value.format].serialization_library
      parameters            = local.storage_formats[each.value.format].serialization_parameters
    }

    dynamic "columns" {
      for_each = each.value.columns

      content {
        name    = columns.value.name
        type    = columns.value.type
        comment = columns.value.description
      }
    }
  }

  dynamic "partition_keys" {
    for_each = try(each.value.partition_keys, [])

    content {
      # Glue requires a type for each partition key, but the dataset contract
      # defines partition key names only. Hive-compatible string is the
      # fallback when the key is not also defined as a table column.
      name = partition_keys.value
      type = try(
        [for column in each.value.columns : column.type if column.name == partition_keys.value][0],
        "string"
      )
    }
  }

  lifecycle {
    precondition {
      condition     = each.key == each.value.dataset
      error_message = "Each datasets key must match the dataset field in its schema file."
    }

    precondition {
      condition     = each.value.layer == var.layer_name
      error_message = "Each schema file layer must match layer_name."
    }

    precondition {
      condition     = contains(keys(local.storage_formats), each.value.format)
      error_message = "Dataset schemas must use a supported storage format: csv or parquet."
    }
  }
}
