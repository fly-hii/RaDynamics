# Terraform AWS CloudFront Module - Variables
# Comprehensive variable definitions for CloudFront module

# Basic Configuration
variable "distribution_name" {
  description = "Name for the CloudFront distribution"
  type        = string
}

variable "comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "Price class for the distribution"
  type        = string
  default     = "PriceClass_All"
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200",
      "PriceClass_100"
    ], var.price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource"
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "Wait for the distribution to be deployed before returning"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Object that you want CloudFront to return when an end user requests the root URL"
  type        = string
  default     = "index.html"
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution"
  type        = list(string)
  default     = []
}

# Origins Configuration
variable "origins" {
  description = "One or more origins for this distribution"
  type = list(object({
    domain_name              = string
    origin_id                = string
    origin_path              = optional(string, "")
    connection_attempts      = optional(number, 3)
    connection_timeout       = optional(number, 10)
    use_origin_access_control = optional(bool, false)
    origin_access_control_id = optional(string, null)
    
    s3_origin_config = optional(object({
      origin_access_identity = string
    }), null)
    
    custom_origin_config = optional(object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_protocol_policy   = string
      origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }), null)
    
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    
    origin_shield = optional(object({
      enabled              = bool
      origin_shield_region = string
    }), null)
  }))
}

# Cache Behaviors
variable "default_cache_behavior" {
  description = "Default cache behavior for this distribution"
  type = object({
    target_origin_id         = string
    allowed_methods          = optional(list(string), ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
    cached_methods           = optional(list(string), ["GET", "HEAD"])
    compress                 = optional(bool, true)
    field_level_encryption_id = optional(string, null)
    cache_policy_id          = optional(string, null)
    origin_request_policy_id = optional(string, null)
    response_headers_policy_id = optional(string, null)
    realtime_log_config_arn  = optional(string, null)
    trusted_key_groups       = optional(list(string), [])
    trusted_signers          = optional(list(string), [])
    
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
    
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
    
    # Legacy forwarded values (use cache policies instead)
    use_forwarded_values = optional(bool, false)
    forwarded_values = optional(object({
      query_string = bool
      headers      = optional(list(string), [])
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string), [])
      })
    }), null)
    
    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 86400)
    max_ttl     = optional(number, 31536000)
  })
}

variable "ordered_cache_behaviors" {
  description = "Ordered list of cache behaviors resource for this distribution"
  type = list(object({
    path_pattern             = string
    target_origin_id         = string
    viewer_protocol_policy   = string
    allowed_methods          = optional(list(string), ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
    cached_methods           = optional(list(string), ["GET", "HEAD"])
    compress                 = optional(bool, true)
    field_level_encryption_id = optional(string, null)
    cache_policy_id          = optional(string, null)
    origin_request_policy_id = optional(string, null)
    response_headers_policy_id = optional(string, null)
    realtime_log_config_arn  = optional(string, null)
    trusted_key_groups       = optional(list(string), [])
    trusted_signers          = optional(list(string), [])
    
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
    
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
    
    # Legacy forwarded values
    use_forwarded_values = optional(bool, false)
    forwarded_values = optional(object({
      query_string = bool
      headers      = optional(list(string), [])
      cookies = object({
        forward           = string
        whitelisted_names = optional(list(string), [])
      })
    }), null)
    
    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 86400)
    max_ttl     = optional(number, 31536000)
  }))
  default = []
}

# Security Configuration
variable "viewer_protocol_policy" {
  description = "Use this element to specify the protocol that users can use to access the files"
  type        = string
  default     = "redirect-to-https"
  validation {
    condition = contains([
      "allow-all",
      "https-only",
      "redirect-to-https"
    ], var.viewer_protocol_policy)
    error_message = "Viewer protocol policy must be one of: allow-all, https-only, redirect-to-https."
  }
}

variable "web_acl_id" {
  description = "Unique identifier that specifies the AWS WAF web ACL"
  type        = string
  default     = null
}

variable "geo_restriction" {
  description = "Geographic restriction configuration"
  type = object({
    restriction_type = string
    locations        = optional(list(string), [])
  })
  default = {
    restriction_type = "none"
    locations        = []
  }
}

variable "viewer_certificate" {
  description = "SSL configuration for this distribution"
  type = object({
    acm_certificate_arn            = optional(string, null)
    cloudfront_default_certificate = optional(bool, true)
    iam_certificate_id             = optional(string, null)
    minimum_protocol_version       = optional(string, "TLSv1.2_2021")
    ssl_support_method             = optional(string, null)
  })
  default = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

# Custom Error Responses
variable "custom_error_responses" {
  description = "One or more custom error response elements"
  type = list(object({
    error_code            = number
    response_code         = optional(number, null)
    response_page_path    = optional(string, null)
    error_caching_min_ttl = optional(number, null)
  }))
  default = []
}

# Origin Access Control
variable "create_origin_access_control" {
  description = "Controls if CloudFront origin access control should be created"
  type        = bool
  default     = false
}

variable "origin_access_control_origin_type" {
  description = "The type of origin that this Origin Access Control is for"
  type        = string
  default     = "s3"
  validation {
    condition = contains([
      "s3",
      "mediastore"
    ], var.origin_access_control_origin_type)
    error_message = "Origin access control origin type must be either 's3' or 'mediastore'."
  }
}

variable "origin_access_control_signing_behavior" {
  description = "Specifies which requests CloudFront signs"
  type        = string
  default     = "always"
  validation {
    condition = contains([
      "always",
      "never",
      "no-override"
    ], var.origin_access_control_signing_behavior)
    error_message = "Origin access control signing behavior must be one of: always, never, no-override."
  }
}

variable "origin_access_control_signing_protocol" {
  description = "Determines how CloudFront signs (authenticates) requests"
  type        = string
  default     = "sigv4"
  validation {
    condition = contains([
      "sigv4"
    ], var.origin_access_control_signing_protocol)
    error_message = "Origin access control signing protocol must be 'sigv4'."
  }
}

# Logging Configuration
variable "enable_logging" {
  description = "Whether to enable logging for the distribution"
  type        = bool
  default     = false
}

variable "logging_config" {
  description = "Logging configuration for the distribution"
  type = object({
    bucket          = string
    prefix          = optional(string, "")
    include_cookies = optional(bool, false)
  })
  default = {
    bucket = ""
  }
}

# Security Headers
variable "enable_security_headers" {
  description = "Whether to enable security headers"
  type        = bool
  default     = true
}

variable "create_security_headers_policy" {
  description = "Whether to create a security headers policy"
  type        = bool
  default     = true
}

variable "security_headers" {
  description = "Security headers configuration"
  type = object({
    frame_options                = optional(string, "DENY")
    referrer_policy             = optional(string, "strict-origin-when-cross-origin")
    content_security_policy     = optional(string, "default-src 'self'")
    hsts_max_age               = optional(number, 31536000)
    hsts_include_subdomains    = optional(bool, true)
    hsts_preload               = optional(bool, true)
  })
  default = {
    frame_options                = "DENY"
    referrer_policy             = "strict-origin-when-cross-origin"
    content_security_policy     = "default-src 'self'"
    hsts_max_age               = 31536000
    hsts_include_subdomains    = true
    hsts_preload               = true
  }
}

# CORS Configuration
variable "cors_config" {
  description = "CORS configuration for the response headers policy"
  type = object({
    access_control_allow_credentials = bool
    access_control_allow_headers     = list(string)
    access_control_allow_methods     = list(string)
    access_control_allow_origins     = list(string)
    access_control_expose_headers    = optional(list(string), [])
    access_control_max_age_sec       = optional(number, 600)
    origin_override                  = optional(bool, true)
  })
  default = null
}

# Custom Headers
variable "custom_headers" {
  description = "Custom headers to add to responses"
  type = list(object({
    header   = string
    value    = string
    override = optional(bool, true)
  }))
  default = []
}

# Monitoring and Alarms
variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = false
}

variable "origin_latency_threshold" {
  description = "Threshold for origin latency alarm (in milliseconds)"
  type        = number
  default     = 1000
}

variable "error_rate_threshold" {
  description = "Threshold for error rate alarm (percentage)"
  type        = number
  default     = 5
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

# Security Controls
variable "security_controls_enabled" {
  description = "Whether to enable security controls validation"
  type        = bool
  default     = true
}

variable "require_https" {
  description = "Whether to require HTTPS for all requests"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Whether to enable WAF protection"
  type        = bool
  default     = false
}

# CCMS Compliance Tags
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition = contains([
      "dev",
      "staging",
      "prod"
    ], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

variable "business_unit" {
  description = "Business unit"
  type        = string
}

variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
  validation {
    condition = contains([
      "public",
      "internal",
      "confidential",
      "restricted"
    ], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "security_compliance_tags" {
  description = "Additional security compliance tags"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}