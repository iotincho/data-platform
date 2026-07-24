variable "project_name" {
  description = "Project identifier used in resource names and common tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier used in resource names and common tags."
  type        = string
}

variable "aws_region" {
  description = "AWS region where platform resources are deployed."
  type        = string
}
