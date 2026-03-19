terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Get current AWS region
data "aws_region" "current" {}

# REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = var.api_name
  description = var.description

  endpoint_configuration {
    types = var.endpoint_types
  }

  policy = var.policy

  api_key_source               = var.api_key_source
  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  minimum_compression_size     = var.minimum_compression_size

  tags = var.tags
}

# API Gateway Resources
resource "aws_api_gateway_resource" "resources" {
  count = length(var.resources)

  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = var.resources[count.index].parent_id == "root" ? aws_api_gateway_rest_api.main.root_resource_id : var.resources[count.index].parent_id
  path_part   = var.resources[count.index].path_part
}

# API Gateway Methods
resource "aws_api_gateway_method" "methods" {
  count = length(var.methods)

  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = var.methods[count.index].resource_index != null ? aws_api_gateway_resource.resources[var.methods[count.index].resource_index].id : aws_api_gateway_rest_api.main.root_resource_id
  http_method   = var.methods[count.index].http_method
  authorization = var.methods[count.index].authorization

  authorizer_id                    = var.methods[count.index].authorizer_id
  authorization_scopes             = var.methods[count.index].authorization_scopes
  api_key_required                = var.methods[count.index].api_key_required
  operation_name                  = var.methods[count.index].operation_name
  request_models                  = var.methods[count.index].request_models
  request_validator_id            = var.methods[count.index].request_validator_id
  request_parameters              = var.methods[count.index].request_parameters
}

# API Gateway Integrations
resource "aws_api_gateway_integration" "integrations" {
  count = length(var.integrations)

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = var.integrations[count.index].resource_index != null ? aws_api_gateway_resource.resources[var.integrations[count.index].resource_index].id : aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.methods[var.integrations[count.index].method_index].http_method

  integration_http_method = var.integrations[count.index].integration_http_method
  type                   = var.integrations[count.index].type
  connection_type        = var.integrations[count.index].connection_type
  connection_id          = var.integrations[count.index].connection_id
  uri                    = var.integrations[count.index].uri
  credentials            = var.integrations[count.index].credentials
  request_templates      = var.integrations[count.index].request_templates
  request_parameters     = var.integrations[count.index].request_parameters
  passthrough_behavior   = var.integrations[count.index].passthrough_behavior
  cache_key_parameters   = var.integrations[count.index].cache_key_parameters
  cache_namespace        = var.integrations[count.index].cache_namespace
  content_handling       = var.integrations[count.index].content_handling
  timeout_milliseconds   = var.integrations[count.index].timeout_milliseconds

  dynamic "tls_config" {
    for_each = var.integrations[count.index].tls_config != null ? [var.integrations[count.index].tls_config] : []
    content {
      insecure_skip_verification = tls_config.value.insecure_skip_verification
    }
  }
}

# API Gateway Method Responses
resource "aws_api_gateway_method_response" "method_responses" {
  count = length(var.method_responses)

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = var.method_responses[count.index].resource_index != null ? aws_api_gateway_resource.resources[var.method_responses[count.index].resource_index].id : aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.methods[var.method_responses[count.index].method_index].http_method
  status_code = var.method_responses[count.index].status_code

  response_models     = var.method_responses[count.index].response_models
  response_parameters = var.method_responses[count.index].response_parameters
}

# API Gateway Integration Responses
resource "aws_api_gateway_integration_response" "integration_responses" {
  count = length(var.integration_responses)

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = var.integration_responses[count.index].resource_index != null ? aws_api_gateway_resource.resources[var.integration_responses[count.index].resource_index].id : aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.methods[var.integration_responses[count.index].method_index].http_method
  status_code = aws_api_gateway_method_response.method_responses[var.integration_responses[count.index].method_response_index].status_code

  response_templates = var.integration_responses[count.index].response_templates
  response_parameters = var.integration_responses[count.index].response_parameters
  selection_pattern  = var.integration_responses[count.index].selection_pattern
  content_handling   = var.integration_responses[count.index].content_handling

  depends_on = [aws_api_gateway_integration.integrations]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  count = var.create_deployment ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resources,
      aws_api_gateway_method.methods,
      aws_api_gateway_integration.integrations,
      aws_api_gateway_method_response.method_responses,
      aws_api_gateway_integration_response.integration_responses,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.methods,
    aws_api_gateway_integration.integrations,
    aws_api_gateway_method_response.method_responses,
    aws_api_gateway_integration_response.integration_responses,
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  count = var.create_stage ? 1 : 0

  deployment_id = var.create_deployment ? aws_api_gateway_deployment.main[0].id : var.deployment_id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size
  client_certificate_id = var.client_certificate_id
  description          = var.stage_description
  documentation_version = var.documentation_version
  variables            = var.stage_variables

  dynamic "access_log_settings" {
    for_each = var.access_log_settings != null ? [var.access_log_settings] : []
    content {
      destination_arn = access_log_settings.value.destination_arn
      format         = access_log_settings.value.format
    }
  }

  xray_tracing_enabled = var.xray_tracing_enabled

  tags = var.tags
}

# API Gateway Authorizers
resource "aws_api_gateway_authorizer" "authorizers" {
  count = length(var.authorizers)

  name                   = var.authorizers[count.index].name
  rest_api_id           = aws_api_gateway_rest_api.main.id
  authorizer_uri        = var.authorizers[count.index].authorizer_uri
  authorizer_credentials = var.authorizers[count.index].authorizer_credentials
  authorizer_result_ttl_in_seconds = var.authorizers[count.index].authorizer_result_ttl_in_seconds
  identity_source       = var.authorizers[count.index].identity_source
  type                  = var.authorizers[count.index].type
  identity_validation_expression = var.authorizers[count.index].identity_validation_expression
  provider_arns         = var.authorizers[count.index].provider_arns
}

# API Gateway Models
resource "aws_api_gateway_model" "models" {
  count = length(var.models)

  rest_api_id  = aws_api_gateway_rest_api.main.id
  name         = var.models[count.index].name
  content_type = var.models[count.index].content_type
  schema       = var.models[count.index].schema
}

# API Gateway Request Validators
resource "aws_api_gateway_request_validator" "validators" {
  count = length(var.request_validators)

  name                        = var.request_validators[count.index].name
  rest_api_id                = aws_api_gateway_rest_api.main.id
  validate_request_body       = var.request_validators[count.index].validate_request_body
  validate_request_parameters = var.request_validators[count.index].validate_request_parameters
}

# API Gateway Usage Plan
resource "aws_api_gateway_usage_plan" "main" {
  count = var.create_usage_plan ? 1 : 0

  name         = var.usage_plan_name
  description  = var.usage_plan_description
  product_code = var.usage_plan_product_code

  dynamic "api_stages" {
    for_each = var.usage_plan_api_stages
    content {
      api_id = aws_api_gateway_rest_api.main.id
      stage  = api_stages.value.stage
      
      dynamic "throttle" {
        for_each = api_stages.value.throttle != null ? api_stages.value.throttle : {}
        content {
          path        = throttle.key
          rate_limit  = throttle.value.rate_limit
          burst_limit = throttle.value.burst_limit
        }
      }
    }
  }

  dynamic "quota_settings" {
    for_each = var.usage_plan_quota_settings != null ? [var.usage_plan_quota_settings] : []
    content {
      limit  = quota_settings.value.limit
      offset = quota_settings.value.offset
      period = quota_settings.value.period
    }
  }

  dynamic "throttle_settings" {
    for_each = var.usage_plan_throttle_settings != null ? [var.usage_plan_throttle_settings] : []
    content {
      rate_limit  = throttle_settings.value.rate_limit
      burst_limit = throttle_settings.value.burst_limit
    }
  }

  tags = var.tags
}

# API Gateway API Keys
resource "aws_api_gateway_api_key" "keys" {
  count = length(var.api_keys)

  name        = var.api_keys[count.index].name
  description = var.api_keys[count.index].description
  enabled     = var.api_keys[count.index].enabled
  value       = var.api_keys[count.index].value

  tags = var.tags
}

# API Gateway Usage Plan Key
resource "aws_api_gateway_usage_plan_key" "main" {
  count = var.create_usage_plan && length(var.api_keys) > 0 ? length(var.api_keys) : 0

  key_id        = aws_api_gateway_api_key.keys[count.index].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main[0].id
}