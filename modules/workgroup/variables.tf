variable "project_name" {
  description = "Project identifier used in workgroup resource tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier used in workgroup resource tags."
  type        = string
}

variable "resource_name_prefix" {
  description = "Foundation-provided prefix used to construct resource names."
  type        = string
}

variable "common_tags" {
  description = "Common tags supplied by the Foundation domain."
  type        = map(string)
}

variable "workgroup_name" {
  description = "Name of the Athena query environment."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.workgroup_name))
    error_message = "workgroup_name must use lowercase letters, numbers, and hyphens."
  }
}
