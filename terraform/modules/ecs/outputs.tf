output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = length(aws_ecs_cluster_capacity_providers.main) > 0 ? aws_ecs_cluster_capacity_providers.main[0] : null
}

output "ec2_capacity_provider_arn" {
  description = "ARN of the EC2 capacity provider"
  value       = var.create_ec2_capacity_provider ? aws_ecs_capacity_provider.ec2[0].arn : null
}

output "ec2_capacity_provider_name" {
  description = "Name of the EC2 capacity provider"
  value       = var.create_ec2_capacity_provider ? aws_ecs_capacity_provider.ec2[0].name : null
}

output "task_definition_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)"
  value       = var.create_task_definition ? aws_ecs_task_definition.main[0].arn : null
}

output "task_definition_family" {
  description = "Family of the Task Definition"
  value       = var.create_task_definition ? aws_ecs_task_definition.main[0].family : null
}

output "task_definition_revision" {
  description = "Revision of the Task Definition"
  value       = var.create_task_definition ? aws_ecs_task_definition.main[0].revision : null
}

output "service_id" {
  description = "ARN that identifies the service"
  value       = var.create_service ? aws_ecs_service.main[0].id : null
}

output "service_name" {
  description = "Name of the service"
  value       = var.create_service ? aws_ecs_service.main[0].name : null
}

output "service_cluster" {
  description = "Amazon Resource Name (ARN) of cluster which the service runs on"
  value       = var.create_service ? aws_ecs_service.main[0].cluster : null
}

output "service_desired_count" {
  description = "Number of instances of the task definition"
  value       = var.create_service ? aws_ecs_service.main[0].desired_count : null
}

output "service_iam_role" {
  description = "ARN of IAM role used for ELB"
  value       = var.create_service ? aws_ecs_service.main[0].iam_role : null
}

output "service_launch_type" {
  description = "Launch type on which to run your service"
  value       = var.create_service ? aws_ecs_service.main[0].launch_type : null
}

output "service_platform_version" {
  description = "Platform version on which to run your service"
  value       = var.create_service ? aws_ecs_service.main[0].platform_version : null
}

output "service_task_definition" {
  description = "Family and revision (family:revision) or full ARN of the task definition that you want to run in your service"
  value       = var.create_service ? aws_ecs_service.main[0].task_definition : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecs[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.ecs[0].arn : null
}

output "cpu_utilization_alarm_id" {
  description = "ID of the CPU utilization CloudWatch alarm"
  value       = var.create_service && var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cpu_utilization[0].id : null
}

output "cpu_utilization_alarm_arn" {
  description = "ARN of the CPU utilization CloudWatch alarm"
  value       = var.create_service && var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cpu_utilization[0].arn : null
}

output "memory_utilization_alarm_id" {
  description = "ID of the memory utilization CloudWatch alarm"
  value       = var.create_service && var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.memory_utilization[0].id : null
}

output "memory_utilization_alarm_arn" {
  description = "ARN of the memory utilization CloudWatch alarm"
  value       = var.create_service && var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.memory_utilization[0].arn : null
}

# Security Control Validation Outputs
output "security_controls_validation" {
  description = "Security controls validation results"
  value = var.security_controls_enabled ? {
    container_security    = local.container_security_validation
    logging              = local.logging_validation
    execute_command      = local.execute_command_validation
    secrets_management   = local.secrets_validation
    encryption          = local.encryption_validation
  } : null
}