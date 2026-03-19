# Outputs for Security Group Basic Example

output "security-group_id" {
  description = "The ID of the Security Group"
  value       = module.security-group_basic.security-group_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.security-group_basic.security_controls_status
}