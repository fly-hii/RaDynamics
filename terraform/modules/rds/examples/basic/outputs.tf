# Outputs for RDS Basic Example

output "rds_id" {
  description = "The ID of the RDS"
  value       = module.rds_basic.rds_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.rds_basic.security_controls_status
}