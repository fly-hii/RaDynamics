# Outputs for IAM Role Basic Example

output "iam-role_id" {
  description = "The ID of the IAM Role"
  value       = module.iam-role_basic.iam-role_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.iam-role_basic.security_controls_status
}