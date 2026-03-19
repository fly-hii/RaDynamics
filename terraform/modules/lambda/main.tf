}

# Lambda Function
resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role         = var.role_arn
  handler      = var.handler
  runtime      = var.runtime
  timeout      = var.timeout
  memory_size  = var.memory_size

  filename         = var.filename
  source_code_hash = var.source_code_hash
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version

  description = var.description

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config != null ? [var.dead_letter_config] : []
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                       = var.publish

  layers = var.layers

  tags = var.tags
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  count = var.enable_api_gateway_integration ? 1 : 0

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.api_gateway_source_arn
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "cloudwatch_events" {
  count = var.enable_cloudwatch_events ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.cloudwatch_event_rule_arn
}

# Lambda Permission for S3
resource "aws_lambda_permission" "s3" {
  count = var.enable_s3_trigger ? 1 : 0

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

# Lambda Permission for SNS
resource "aws_lambda_permission" "sns" {
  count = var.enable_sns_trigger ? 1 : 0

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

# Lambda Alias
resource "aws_lambda_alias" "main" {
  count = var.create_alias ? 1 : 0

  name             = var.alias_name
  description      = var.alias_description
  function_name    = aws_lambda_function.main.function_name
  function_version = var.alias_function_version

  dynamic "routing_config" {
    for_each = var.alias_routing_config != null ? [var.alias_routing_config] : []
    content {
      additional_version_weights = routing_config.value.additional_version_weights
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}

# Lambda Event Source Mapping for SQS
resource "aws_lambda_event_source_mapping" "sqs" {
  count = var.enable_sqs_trigger ? 1 : 0

  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.main.arn
  batch_size       = var.sqs_batch_size
  
  dynamic "filter_criteria" {
    for_each = var.sqs_filter_criteria != null ? [var.sqs_filter_criteria] : []
    content {
      dynamic "filter" {
        for_each = filter_criteria.value.filters
        content {
          pattern = filter.value.pattern
        }
      }
    }
  }
}

# Lambda Event Source Mapping for DynamoDB
resource "aws_lambda_event_source_mapping" "dynamodb" {
  count = var.enable_dynamodb_trigger ? 1 : 0

  event_source_arn  = var.dynamodb_stream_arn
  function_name     = aws_lambda_function.main.arn
  starting_position = var.dynamodb_starting_position
  batch_size        = var.dynamodb_batch_size
}

# Lambda Event Source Mapping for Kinesis
resource "aws_lambda_event_source_mapping" "kinesis" {
  count = var.enable_kinesis_trigger ? 1 : 0

  event_source_arn  = var.kinesis_stream_arn
  function_name     = aws_lambda_function.main.arn
  starting_position = var.kinesis_starting_position
  batch_size        = var.kinesis_batch_size
}