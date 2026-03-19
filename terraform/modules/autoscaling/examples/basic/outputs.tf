# Outputs for Auto Scaling Basic Example

output "autoscaling_id" {
  description = "The ID of the Auto Scaling"
  value       = module.autoscaling_basic.autoscaling_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.autoscaling_basic.security_controls_status
}