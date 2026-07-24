output "project_name" {
  description = "Project identifier used by platform domains."
  value       = var.project_name
}

output "environment" {
  description = "Deployment environment identifier used by platform domains."
  value       = var.environment
}

output "aws_region" {
  description = "AWS region where platform resources are deployed."
  value       = var.aws_region
}

output "common_tags" {
  description = "Common tags applied to platform resources."
  value       = local.common_tags
}

output "resource_name_prefix" {
  description = "Prefix used to construct platform resource names."
  value       = local.resource_name_prefix
}
