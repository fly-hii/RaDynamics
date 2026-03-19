# API Gateway Outputs

output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "rest_api_arn" {
  description = "ARN of the REST API"
  value       = aws_api_gateway_rest_api.main.arn
}

output "rest_api_name" {
  description = "Name of the REST API"
  value       = aws_api_gateway_rest_api.main.name
}

output "rest_api_description" {
  description = "Description of the REST API"
  value       = aws_api_gateway_rest_api.main.description
}

output "rest_api_root_resource_id" {
  description = "Resource ID of the REST API's root"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}

output "rest_api_execution_arn" {
  description = "Execution ARN part to be used in lambda_permission's source_arn"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "rest_api_created_date" {
  description = "Creation date of the REST API"
  value       = aws_api_gateway_rest_api.main.created_date
}

output "rest_api_policy" {
  description = "JSON formatted policy document that controls access to the API Gateway"
  value       = aws_api_gateway_rest_api.main.policy
}

output "rest_api_endpoint_configuration" {
  description = "Configuration block of the endpoint"
  value       = aws_api_gateway_rest_api.main.endpoint_configuration
}

# Resources
output "resource_ids" {
  description = "List of API Gateway resource IDs"
  value       = aws_api_gateway_resource.resources[*].id
}

output "resource_paths" {
  description = "List of complete paths for API Gateway resources"
  value       = aws_api_gateway_resource.resources[*].path
}

# Methods
output "method_ids" {
  description = "List of API Gateway method IDs"
  value       = [for method in aws_api_gateway_method.methods : "${method.rest_api_id}/${method.resource_id}/${method.http_method}"]
}

# Deployment
output "deployment_id" {
  description = "ID of the deployment"
  value       = var.create_deployment ? aws_api_gateway_deployment.main[0].id : null
}

output "deployment_invoke_url" {
  description = "URL to invoke the API pointing to the stage"
  value       = var.create_deployment && var.create_stage ? "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.main[0].stage_name}" : null
}

output "deployment_execution_arn" {
  description = "Execution ARN to be used in lambda_permission's source_arn"
  value       = var.create_deployment ? aws_api_gateway_deployment.main[0].execution_arn : null
}

output "deployment_created_date" {
  description = "Creation date of the deployment"
  value       = var.create_deployment ? aws_api_gateway_deployment.main[0].created_date : null
}

# Stage
output "stage_id" {
  description = "ID of the stage"
  value       = var.create_stage ? aws_api_gateway_stage.main[0].id : null
}

output "stage_arn" {
  description = "ARN of the stage"
  value       = var.create_stage ? aws_api_gateway_stage.main[0].arn : null
}

output "stage_invoke_url" {
  description = "URL to invoke the API pointing to the stage"
  value       = var.create_stage ? "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.main[0].stage_name}" : null
}

output "stage_execution_arn" {
  description = "Execution ARN to be used in lambda_permission's source_arn"
  value       = var.create_stage ? aws_api_gateway_stage.main[0].execution_arn : null
}

output "stage_name" {
  description = "Name of the stage"
  value       = var.create_stage ? aws_api_gateway_stage.main[0].stage_name : null
}

# Authorizers
output "authorizer_ids" {
  description = "List of API Gateway authorizer IDs"
  value       = aws_api_gateway_authorizer.authorizers[*].id
}

output "authorizer_arns" {
  description = "List of API Gateway authorizer ARNs"
  value       = aws_api_gateway_authorizer.authorizers[*].arn
}

# Models
output "model_names" {
  description = "List of API Gateway model names"
  value       = aws_api_gateway_model.models[*].name
}

# Request Validators
output "request_validator_ids" {
  description = "List of API Gateway request validator IDs"
  value       = aws_api_gateway_request_validator.validators[*].id
}

# Usage Plan
output "usage_plan_id" {
  description = "ID of the usage plan"
  value       = var.create_usage_plan ? aws_api_gateway_usage_plan.main[0].id : null
}

output "usage_plan_arn" {
  description = "ARN of the usage plan"
  value       = var.create_usage_plan ? aws_api_gateway_usage_plan.main[0].arn : null
}

output "usage_plan_name" {
  description = "Name of the usage plan"
  value       = var.create_usage_plan ? aws_api_gateway_usage_plan.main[0].name : null
}

# API Keys
output "api_key_ids" {
  description = "List of API key IDs"
  value       = aws_api_gateway_api_key.keys[*].id
}

output "api_key_arns" {
  description = "List of API key ARNs"
  value       = aws_api_gateway_api_key.keys[*].arn
}

output "api_key_names" {
  description = "List of API key names"
  value       = aws_api_gateway_api_key.keys[*].name
}

output "api_key_values" {
  description = "List of API key values"
  value       = aws_api_gateway_api_key.keys[*].value
  sensitive   = true
}