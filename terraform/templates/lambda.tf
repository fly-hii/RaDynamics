# Lambda Function Terraform Template
# This template creates a Lambda function with comprehensive configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.function_name}-role"
      Environment = var.environment_name
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Lambda Function
resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role         = aws_iam_role.lambda_role.arn
  handler      = var.handler
  runtime      = var.runtime
  
  # Simple inline code for testing
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  # Function Configuration
  description = var.description
  timeout     = var.timeout
  memory_size = var.memory_size
  
  # Environment Variables
  dynamic "environment" {
    for_each = length(var.environment) > 0 ? [var.environment] : []
    content {
      variables = environment.value
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name        = var.function_name
      Environment = var.environment_name
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# Create a simple Lambda function code
resource "local_file" "lambda_code" {
  content = <<EOF
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda! Function: ${var.function_name}'
    }
EOF
  filename = "${path.module}/lambda_function.py"
}

# Create ZIP file for Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = local_file.lambda_code.filename
  output_path = "${path.module}/lambda_function.zip"
  depends_on  = [local_file.lambda_code]
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

variable "environment_name" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
}

variable "role" {
  description = "IAM role ARN attached to the Lambda Function"
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "code" {
  description = "Simple code configuration (not used - auto-generated)"
  type        = string
  default     = "auto-generated"
}

variable "description" {
  description = "Description of what your Lambda Function does"
  type        = string
  default     = "Lambda function created by IndraSuite"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "environment" {
  description = "The Lambda environment's configuration settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "function_arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function"
  value       = aws_lambda_function.main.arn
}

output "function_name" {
  description = "The unique name of your Lambda Function"
  value       = aws_lambda_function.main.function_name
}

output "invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway"
  value       = aws_lambda_function.main.invoke_arn
}

output "qualified_arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function Version"
  value       = aws_lambda_function.main.qualified_arn
}

output "version" {
  description = "Latest published version of your Lambda Function"
  value       = aws_lambda_function.main.version
}

output "last_modified" {
  description = "The date this resource was last modified"
  value       = aws_lambda_function.main.last_modified
}

output "source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = aws_lambda_function.main.source_code_hash
}

output "source_code_size" {
  description = "The size in bytes of the function .zip file"
  value       = aws_lambda_function.main.source_code_size
}