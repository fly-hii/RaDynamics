# Outputs for Elastic Container Registry Basic Example

output "ecr_id" {
  description = "The ID of the Elastic Container Registry"
  value       = module.ecr_basic.ecr_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.ecr_basic.security_controls_status
}