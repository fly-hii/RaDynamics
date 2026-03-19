# API Gateway Variables

variable "api_name" {
  description = "Name of the REST API"
  type        = string
}

variable "description" {
  description = "Description of the REST API"
  type        = string
  default     = ""
}

variable "endpoint_types" {
  description = "List of endpoint types. Valid values: EDGE, REGIONAL or PRIVATE"
  type        = list(string)
  default     = ["REGIONAL"]
}

variable "policy" {
  description = "JSON formatted policy document that controls access to the API Gateway"
  type        = string
  default     = null
}

variable "api_key_source" {
  description = "Source of the API key for requests. Valid values are HEADER (default) and AUTHORIZER"
  type        = string
  default     = "HEADER"
}

variable "disable_execute_api_endpoint" {
  description = "Whether clients can invoke your API by using the default execute-api endpoint"
  type        = bool
  default     = false
}

variable "minimum_compression_size" {
  description = "Minimum response size to compress for the REST API"
  type        = number
  default     = -1
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Resources
variable "resources" {
  description = "List of API Gateway resources"
  type = list(object({
    path_part = string
    parent_id = string
  }))
  default = []
}

# Methods
variable "methods" {
  description = "List of API Gateway methods"
  type = list(object({
    resource_index           = optional(number)
    http_method             = string
    authorization           = string
    authorizer_id           = optional(string)
    authorization_scopes    = optional(list(string))
    api_key_required        = optional(bool, false)
    operation_name          = optional(string)
    request_models          = optional(map(string))
    request_validator_id    = optional(string)
    request_parameters      = optional(map(bool))
  }))
  default = []
}

# Integrations
variable "integrations" {
  description = "List of API Gateway integrations"
  type = list(object({
    resource_index          = optional(number)
    method_index           = number
    integration_http_method = optional(string)
    type                   = string
    connection_type        = optional(string, "INTERNET")
    connection_id          = optional(string)
    uri                    = optional(string)
    credentials            = optional(string)
    request_templates      = optional(map(string))
    request_parameters     = optional(map(string))
    passthrough_behavior   = optional(string)
    cache_key_parameters   = optional(list(string))
    cache_namespace        = optional(string)
    content_handling       = optional(string)
    timeout_milliseconds   = optional(number, 29000)
    tls_config = optional(object({
      insecure_skip_verification = bool
    }))
  }))
  default = []
}

# Method Responses
variable "method_responses" {
  description = "List of API Gateway method responses"
  type = list(object({
    resource_index      = optional(number)
    method_index       = number
    status_code        = string
    response_models    = optional(map(string))
    response_parameters = optional(map(bool))
  }))
  default = []
}

# Integration Responses
variable "integration_responses" {
  description = "List of API Gateway integration responses"
  type = list(object({
    resource_index         = optional(number)
    method_index          = number
    method_response_index = number
    status_code           = string
    response_templates    = optional(map(string))
    response_parameters   = optional(map(string))
    selection_pattern     = optional(string)
    content_handling      = optional(string)
  }))
  default = []
}

# Deployment
variable "create_deployment" {
  description = "Whether to create a deployment"
  type        = bool
  default     = true
}

variable "deployment_id" {
  description = "ID of the deployment to use if create_deployment is false"
  type        = string
  default     = null
}

# Stage
variable "create_stage" {
  description = "Whether to create a stage"
  type        = bool
  default     = true
}

variable "stage_name" {
  description = "Name of the stage"
  type        = string
  default     = "prod"
}

variable "cache_cluster_enabled" {
  description = "Whether a cache cluster is enabled for the stage"
  type        = bool
  default     = false
}

variable "cache_cluster_size" {
  description = "Size of the cache cluster for the stage"
  type        = string
  default     = "0.5"
}

variable "client_certificate_id" {
  description = "Identifier of a client certificate for the stage"
  type        = string
  default     = null
}

variable "stage_description" {
  description = "Description of the stage"
  type        = string
  default     = null
}

variable "documentation_version" {
  description = "Version of the associated API documentation"
  type        = string
  default     = null
}

variable "stage_variables" {
  description = "Map that defines the stage variables"
  type        = map(string)
  default     = {}
}

variable "access_log_settings" {
  description = "Access log settings for the stage"
  type = object({
    destination_arn = string
    format         = string
  })
  default = null
}

variable "xray_tracing_enabled" {
  description = "Whether active tracing with X-ray is enabled"
  type        = bool
  default     = false
}

# Authorizers
variable "authorizers" {
  description = "List of API Gateway authorizers"
  type = list(object({
    name                             = string
    authorizer_uri                   = optional(string)
    authorizer_credentials           = optional(string)
    authorizer_result_ttl_in_seconds = optional(number, 300)
    identity_source                  = optional(string)
    type                            = optional(string, "TOKEN")
    identity_validation_expression   = optional(string)
    provider_arns                   = optional(list(string))
  }))
  default = []
}

# Models
variable "models" {
  description = "List of API Gateway models"
  type = list(object({
    name         = string
    content_type = string
    schema       = string
  }))
  default = []
}

# Request Validators
variable "request_validators" {
  description = "List of API Gateway request validators"
  type = list(object({
    name                        = string
    validate_request_body       = optional(bool, false)
    validate_request_parameters = optional(bool, false)
  }))
  default = []
}

# Usage Plan
variable "create_usage_plan" {
  description = "Whether to create a usage plan"
  type        = bool
  default     = false
}

variable "usage_plan_name" {
  description = "Name of the usage plan"
  type        = string
  default     = null
}

variable "usage_plan_description" {
  description = "Description of the usage plan"
  type        = string
  default     = null
}

variable "usage_plan_product_code" {
  description = "AWS Marketplace product identifier to associate with the usage plan"
  type        = string
  default     = null
}

variable "usage_plan_api_stages" {
  description = "Associated API stages of the usage plan"
  type = list(object({
    stage    = string
    throttle = optional(map(object({
      path        = string
      rate_limit  = number
      burst_limit = number
    })))
  }))
  default = []
}

variable "usage_plan_quota_settings" {
  description = "Quota settings of the usage plan"
  type = object({
    limit  = number
    offset = optional(number, 0)
    period = string
  })
  default = null
}

variable "usage_plan_throttle_settings" {
  description = "Throttle settings of the usage plan"
  type = object({
    rate_limit  = number
    burst_limit = number
  })
  default = null
}

# API Keys
variable "api_keys" {
  description = "List of API keys"
  type = list(object({
    name        = string
    description = optional(string)
    enabled     = optional(bool, true)
    value       = optional(string)
  }))
  default = []
}