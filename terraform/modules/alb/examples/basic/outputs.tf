# Outputs for ALB Basic Example

output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = module.alb_basic.alb_id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = module.alb_basic.alb_arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.alb_basic.alb_dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the Application Load Balancer"
  value       = module.alb_basic.alb_zone_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.alb_basic.security_controls_status
}