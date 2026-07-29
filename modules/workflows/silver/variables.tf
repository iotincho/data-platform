variable "resource_name_prefix" {
  description = "Foundation-provided prefix used to construct resource names."
  type        = string
}

variable "bronze_bucket_name" {
  description = "Name of the bucket that stores Bronze datasets."
  type        = string
}

variable "bronze_database_name" {
  description = "Name of the Glue Catalog database for Bronze datasets."
  type        = string
}

variable "silver_bucket_name" {
  description = "Name of the bucket that stores Silver datasets."
  type        = string
}

variable "silver_database_name" {
  description = "Name of the Glue Catalog database for Silver datasets."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to resources created by the Silver workflow."
  type        = map(string)
  default     = {}
}
