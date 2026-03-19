# Outputs for Elastic Container Service Basic Example

output "ecs_id" {
  description = "The ID of the Elastic Container Service"
  value       = module.ecs_basic.ecs_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.ecs_basic.security_controls_status
}