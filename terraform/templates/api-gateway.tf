# API Gateway Terraform Template
# This template creates an API Gateway with basic configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# API Gateway
resource "aws_apigatewayv2_api" "main" {
  name          = var.api_name
  description   = var.description
  protocol_type = var.protocol_type

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []
    content {
      allow_credentials = lookup(cors_configuration.value, "allow_credentials", false)
      allow_headers     = lookup(cors_configuration.value, "allow_headers", [])
      allow_methods     = lookup(cors_configuration.value, "allow_methods", [])
      allow_origins     = lookup(cors_configuration.value, "allow_origins", [])
      expose_headers    = lookup(cors_configuration.value, "expose_headers", [])
      max_age          = lookup(cors_configuration.value, "max_age", 0)
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.api_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.stage_name
  auto_deploy = true

  dynamic "default_route_settings" {
    for_each = var.throttle_settings != null ? [var.throttle_settings] : []
    content {
      throttling_burst_limit = lookup(default_route_settings.value, "burst_limit", 5000)
      throttling_rate_limit  = lookup(default_route_settings.value, "rate_limit", 10000)
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-${var.stage_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# Default Route (if integration URI is provided)
resource "aws_apigatewayv2_route" "default" {
  count = var.integration_uri != null ? 1 : 0

  api_id    = aws_apigatewayv2_api.main.id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.default[0].id}"
}

# Default Integration (if integration URI is provided)
resource "aws_apigatewayv2_integration" "default" {
  count = var.integration_uri != null ? 1 : 0

  api_id           = aws_apigatewayv2_api.main.id
  integration_type = var.integration_type
  integration_uri  = var.integration_uri

  payload_format_version = var.payload_format_version
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "deployment_id" {
  description = "Deployment ID"
  type        = string
  default     = ""
}

variable "created_by" {
  description = "Created by user"
  type        = string
  default     = "terraform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "api_name" {
  description = "The name of the API"
  type        = string
}

variable "description" {
  description = "The description of the API"
  type        = string
  default     = "API Gateway created by IndraSuite"
}

variable "protocol_type" {
  description = "The API protocol"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "WEBSOCKET"], var.protocol_type)
    error_message = "Protocol type must be either 'HTTP' or 'WEBSOCKET'."
  }
}

variable "cors_configuration" {
  description = "The cross-origin resource sharing (CORS) configuration"
  type        = any
  default     = null
}

variable "route_key" {
  description = "The route key for the route"
  type        = string
  default     = "$default"
}

variable "integration_uri" {
  description = "The URI of the Lambda function for a Lambda proxy integration"
  type        = string
  default     = null
}

variable "integration_type" {
  description = "The integration type of an integration"
  type        = string
  default     = "AWS_PROXY"
}

variable "payload_format_version" {
  description = "The format of the payload sent to an integration"
  type        = string
  default     = "2.0"
}

variable "stage_name" {
  description = "The name of the stage"
  type        = string
  default     = "$default"
}

variable "throttle_settings" {
  description = "The throttle settings for the stage"
  type        = any
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "api_id" {
  description = "The ID of the API"
  value       = aws_apigatewayv2_api.main.id
}

output "api_arn" {
  description = "The ARN of the API"
  value       = aws_apigatewayv2_api.main.arn
}

output "api_endpoint" {
  description = "The URI of the API"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "stage_arn" {
  description = "The ARN of the stage"
  value       = aws_apigatewayv2_stage.main.arn
}

output "stage_invoke_url" {
  description = "The URL to invoke the API pointing to the stage"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "execution_arn" {
  description = "The ARN prefix to be used in an aws_lambda_permission's source_arn attribute"
  value       = aws_apigatewayv2_api.main.execution_arn
}