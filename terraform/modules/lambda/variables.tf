variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role that Lambda assumes when it executes your function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "filename" {
  description = "Path to the function's deployment package within the local filesystem"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Used to trigger updates when file contents change"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket location containing the function's deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of an object containing the function's deployment package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "Object version containing the function's deployment package"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of what your Lambda Function does"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Map of environment variables that are accessible from the function code during execution"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "dead_letter_config" {
  description = "Dead letter queue configuration"
  type = object({
    target_arn = string
  })
  default = null
}

variable "tracing_mode" {
  description = "Tracing mode for AWS X-Ray"
  type        = string
  default     = null
  validation {
    condition     = var.tracing_mode == null || contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "Tracing mode must be either 'Active' or 'PassThrough'."
  }
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function"
  type        = number
  default     = -1
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = bool
  default     = false
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs to attach to your Lambda Function"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Trigger configurations
variable "enable_api_gateway_integration" {
  description = "Enable API Gateway integration"
  type        = bool
  default     = false
}

variable "api_gateway_source_arn" {
  description = "Source ARN for API Gateway integration"
  type        = string
  default     = ""
}

variable "enable_cloudwatch_events" {
  description = "Enable CloudWatch Events trigger"
  type        = bool
  default     = false
}

variable "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule"
  type        = string
  default     = ""
}

variable "enable_s3_trigger" {
  description = "Enable S3 trigger"
  type        = bool
  default     = false
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for trigger"
  type        = string
  default     = ""
}

variable "enable_sns_trigger" {
  description = "Enable SNS trigger"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
  default     = ""
}

# Alias configuration
variable "create_alias" {
  description = "Whether to create a Lambda alias"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "Name for the alias"
  type        = string
  default     = "live"
}

variable "alias_description" {
  description = "Description of the alias"
  type        = string
  default     = ""
}

variable "alias_function_version" {
  description = "Lambda function version for the alias"
  type        = string
  default     = "$LATEST"
}

variable "alias_routing_config" {
  description = "Routing configuration for the alias"
  type = object({
    additional_version_weights = map(number)
  })
  default = null
}

# CloudWatch Logs
variable "create_log_group" {
  description = "Whether to create a CloudWatch Log Group"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events"
  type        = number
  default     = 14
}

# Event Source Mappings
variable "enable_sqs_trigger" {
  description = "Enable SQS trigger"
  type        = bool
  default     = false
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
  default     = ""
}

variable "sqs_batch_size" {
  description = "Largest number of records that Lambda will retrieve from your event source at the time of invoking your function"
  type        = number
  default     = 10
}

variable "sqs_filter_criteria" {
  description = "Filter criteria for SQS events"
  type = object({
    filters = list(object({
      pattern = string
    }))
  })
  default = null
}

variable "enable_dynamodb_trigger" {
  description = "Enable DynamoDB trigger"
  type        = bool
  default     = false
}

variable "dynamodb_stream_arn" {
  description = "ARN of the DynamoDB stream"
  type        = string
  default     = ""
}

variable "dynamodb_starting_position" {
  description = "Position in the DynamoDB stream where AWS Lambda should start reading"
  type        = string
  default     = "LATEST"
}

variable "dynamodb_batch_size" {
  description = "Largest number of records that Lambda will retrieve from your event source at the time of invoking your function"
  type        = number
  default     = 100
}

variable "enable_kinesis_trigger" {
  description = "Enable Kinesis trigger"
  type        = bool
  default     = false
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis stream"
  type        = string
  default     = ""
}

variable "kinesis_starting_position" {
  description = "Position in the Kinesis stream where AWS Lambda should start reading"
  type        = string
  default     = "LATEST"
}

variable "kinesis_batch_size" {
  description = "Largest number of records that Lambda will retrieve from your event source at the time of invoking your function"
  type        = number
  default     = 100
}