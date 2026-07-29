data "aws_iam_policy_document" "execution_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "execution" {
  name               = "job-${var.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "execution" {
  statement {
    sid    = "LocateRuntimeBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
    ]
    resources = [local.runtime_bucket_arn]
  }

  statement {
    sid    = "ReadExecutionScript"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [local.script_arn]
  }

  statement {
    sid       = "LocateInputDatasetBucket"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [local.input_bucket_arn]
  }

  statement {
    sid       = "ListInputDataset"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.input_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [local.input_data_prefix]
    }
  }

  statement {
    sid    = "ReadInputDatasetObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [local.input_data_arn]
  }

  statement {
    sid       = "LocateOutputDatasetBucket"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [local.output_bucket_arn]
  }

  statement {
    sid       = "ListOutputDataset"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.output_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [local.output_data_prefix]
    }
  }

  statement {
    sid    = "WriteOutputDatasetObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [local.output_data_arn]
  }

  statement {
    sid       = "LocateTemporaryStorageBucket"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [local.runtime_bucket_arn]
  }

  statement {
    sid       = "ListTemporaryObjects"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.runtime_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [local.temporary_data_prefix]
    }
  }

  statement {
    sid    = "ManageTemporaryObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [local.temporary_data_arn]
  }

  statement {
    sid    = "ReadDatasetMetadata"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
    ]
    resources = [
      local.glue_catalog_arn,
      local.input_database_arn,
      local.input_table_arn,
      local.output_database_arn,
      local.output_table_arn,
    ]
  }

  statement {
    sid    = "WriteExecutionLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.execution.arn}:*"]
  }
}

resource "aws_iam_role_policy" "execution" {
  name   = "job-${var.name}-execution"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution.json
}
