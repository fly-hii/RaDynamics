output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.main.qualified_arn
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.main.version
}

output "function_last_modified" {
  description = "Date this resource was last modified"
  value       = aws_lambda_function.main.last_modified
}

output "function_source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = aws_lambda_function.main.source_code_hash
}

output "function_source_code_size" {
  description = "Size in bytes of the function .zip file"
  value       = aws_lambda_function.main.source_code_size
}

output "alias_arn" {
  description = "ARN of the Lambda alias"
  value       = var.create_alias ? aws_lambda_alias.main[0].arn : null
}

output "alias_invoke_arn" {
  description = "Invoke ARN of the Lambda alias"
  value       = var.create_alias ? aws_lambda_alias.main[0].invoke_arn : null
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.lambda_logs[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.lambda_logs[0].arn : null
}

output "sqs_event_source_mapping_uuid" {
  description = "UUID of the SQS event source mapping"
  value       = var.enable_sqs_trigger ? aws_lambda_event_source_mapping.sqs[0].uuid : null
}

output "dynamodb_event_source_mapping_uuid" {
  description = "UUID of the DynamoDB event source mapping"
  value       = var.enable_dynamodb_trigger ? aws_lambda_event_source_mapping.dynamodb[0].uuid : null
}

output "kinesis_event_source_mapping_uuid" {
  description = "UUID of the Kinesis event source mapping"
  value       = var.enable_kinesis_trigger ? aws_lambda_event_source_mapping.kinesis[0].uuid : null
}