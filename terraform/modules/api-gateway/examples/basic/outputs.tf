# Outputs for API Gateway Basic Example

output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = module.api_gateway_basic.api_gateway_id
}

output "api_gateway_arn" {
  description = "The ARN of the API Gateway"
  value       = module.api_gateway_basic.api_gateway_arn
}

output "api_gateway_execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = module.api_gateway_basic.api_gateway_execution_arn
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.api_gateway_basic.security_controls_status
}