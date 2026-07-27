variable "project_name" {
  description = "Project identifier used in layer resource tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier used in layer resource tags."
  type        = string
}

variable "common_tags" {
  description = "Common tags supplied by the Foundation domain."
  type        = map(string)
}

variable "resource_name_prefix" {
  description = "Foundation-provided prefix used to construct resource names."
  type        = string
}

variable "layer_name" {
  description = "Data Lake layer name, such as bronze or silver."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.layer_name))
    error_message = "layer_name must use lowercase letters, numbers, and hyphens."
  }
}

variable "datasets" {
  description = "Datasets to register in this layer, keyed by dataset name."

  type = map(object({
    schema_file = string
  }))
}
