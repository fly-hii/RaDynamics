output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.main.arn
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.main.latest_version
}

output "autoscaling_group_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "autoscaling_group_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.min_size
}

output "autoscaling_group_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Default cooldown of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Health check grace period of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "Health check type of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.health_check_type
}

output "autoscaling_group_availability_zones" {
  description = "Availability zones of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.availability_zones
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "VPC zone identifier of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.vpc_zone_identifier
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_scale_up_policy ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_scale_down_policy ? aws_autoscaling_policy.scale_down[0].arn : null
}

output "high_cpu_alarm_id" {
  description = "ID of the high CPU alarm"
  value       = var.enable_scale_up_policy ? aws_cloudwatch_metric_alarm.high_cpu[0].id : null
}

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU alarm"
  value       = var.enable_scale_up_policy ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : null
}

output "low_cpu_alarm_id" {
  description = "ID of the low CPU alarm"
  value       = var.enable_scale_down_policy ? aws_cloudwatch_metric_alarm.low_cpu[0].id : null
}

output "low_cpu_alarm_arn" {
  description = "ARN of the low CPU alarm"
  value       = var.enable_scale_down_policy ? aws_cloudwatch_metric_alarm.low_cpu[0].arn : null
}