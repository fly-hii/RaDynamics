# Outputs for Lambda Basic Example

output "lambda_id" {
  description = "The ID of the Lambda"
  value       = module.lambda_basic.lambda_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.lambda_basic.security_controls_status
}