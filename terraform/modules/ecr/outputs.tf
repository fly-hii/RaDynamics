output "repository_arn" {
  description = "Full ARN of the repository"
  value       = aws_ecr_repository.main.arn
}

output "repository_name" {
  description = "Name of the repository"
  value       = aws_ecr_repository.main.name
}

output "repository_url" {
  description = "URL of the repository"
  value       = aws_ecr_repository.main.repository_url
}

output "registry_id" {
  description = "Registry ID where the repository was created"
  value       = aws_ecr_repository.main.registry_id
}

output "repository_policy" {
  description = "Repository policy"
  value       = var.repository_policy != null ? aws_ecr_repository_policy.main[0].policy : null
}

output "lifecycle_policy" {
  description = "Lifecycle policy"
  value       = var.lifecycle_policy != null ? aws_ecr_lifecycle_policy.main[0].policy : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecr[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecr[0].arn : null
}

output "repository_size_alarm_id" {
  description = "ID of the repository size CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.repository_size[0].id : null
}

output "image_count_alarm_id" {
  description = "ID of the image count CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.image_count[0].id : null
}

# Security Control Validation Outputs
output "security_controls_validation" {
  description = "Security controls validation results"
  value = var.security_controls_enabled ? {
    image_scanning    = local.image_scanning_validation
    encryption       = local.encryption_validation
    access_control   = local.access_control_validation
    lifecycle        = local.lifecycle_validation
  } : null
}