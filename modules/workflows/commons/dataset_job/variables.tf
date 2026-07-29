variable "name" {
  description = "Name of the dataset transformation."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.name))
    error_message = "name must use lowercase letters, numbers, and hyphens."
  }
}

variable "runtime_bucket" {
  description = "Name of the bucket that stores the transformation script and temporary execution files."
  type        = string
}

variable "script_key" {
  description = "Object key of the transformation script in runtime_bucket."
  type        = string

  validation {
    condition     = length(trim(var.script_key, "/")) > 0
    error_message = "script_key must identify an object in runtime_bucket."
  }
}

variable "input_database" {
  description = "Catalog database that contains the input dataset."
  type        = string
}

variable "input_dataset" {
  description = "Name of the dataset read by the transformation."
  type        = string
}

variable "input_data_location" {
  description = "S3 location containing the input dataset. Used to scope read access for the execution environment."
  type        = string

  validation {
    condition     = can(regex("^s3://[^/]+/.+", var.input_data_location))
    error_message = "input_data_location must be an S3 URI that includes a dataset prefix."
  }
}

variable "output_database" {
  description = "Catalog database that contains the output dataset."
  type        = string
}

variable "output_dataset" {
  description = "Name of the dataset produced by the transformation."
  type        = string
}

variable "output_data_location" {
  description = "S3 location where the transformation writes the output dataset. Used to scope write access for the execution environment."
  type        = string

  validation {
    condition     = can(regex("^s3://[^/]+/.+", var.output_data_location))
    error_message = "output_data_location must be an S3 URI that includes a dataset prefix."
  }
}

variable "runtime" {
  description = "Execution capacity and timing requirements for the transformation."

  type = object({
    glue_version = string
    worker_type  = string
    workers      = number
    timeout      = number
  })

  validation {
    condition     = var.runtime.workers > 0
    error_message = "runtime.workers must be greater than zero."
  }

  validation {
    condition     = var.runtime.timeout > 0 && var.runtime.timeout <= 2880
    error_message = "runtime.timeout must be between 1 and 2880 minutes."
  }
}

variable "log_retention_in_days" {
  description = "Number of days to retain execution logs in CloudWatch."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_in_days)
    error_message = "log_retention_in_days must be a supported CloudWatch Logs retention period."
  }
}

variable "tags" {
  description = "Tags applied to resources created for the dataset transformation."
  type        = map(string)
  default     = {}
}
