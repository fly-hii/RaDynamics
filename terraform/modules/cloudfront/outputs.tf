# Terraform AWS CloudFront Module - Outputs
# Comprehensive output definitions for CloudFront module

# CloudFront Distribution Outputs
output "distribution_id" {
  description = "The identifier for the distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "distribution_domain_name" {
  description = "The domain name corresponding to the distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "distribution_status" {
  description = "The current status of the distribution"
  value       = aws_cloudfront_distribution.main.status
}

output "distribution_etag" {
  description = "The current version of the distribution's information"
  value       = aws_cloudfront_distribution.main.etag
}

output "distribution_last_modified_time" {
  description = "The date and time the distribution was last modified"
  value       = aws_cloudfront_distribution.main.last_modified_time
}

output "distribution_in_progress_validation_batches" {
  description = "The number of invalidation batches currently in progress"
  value       = aws_cloudfront_distribution.main.in_progress_validation_batches
}

# Origin Access Control Outputs
output "origin_access_control_id" {
  description = "The unique identifier of the origin access control"
  value       = var.create_origin_access_control ? aws_cloudfront_origin_access_control.main[0].id : null
}

output "origin_access_control_etag" {
  description = "The current version of the origin access control's information"
  value       = var.create_origin_access_control ? aws_cloudfront_origin_access_control.main[0].etag : null
}

# Security Headers Policy Outputs
output "security_headers_policy_id" {
  description = "The unique identifier of the response headers policy"
  value       = var.create_security_headers_policy ? aws_cloudfront_response_headers_policy.security_headers[0].id : null
}

output "security_headers_policy_etag" {
  description = "The current version of the response headers policy"
  value       = var.create_security_headers_policy ? aws_cloudfront_response_headers_policy.security_headers[0].etag : null
}

# CloudWatch Alarms Outputs
output "origin_latency_alarm_arn" {
  description = "The ARN of the origin latency CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.origin_latency[0].arn : null
}

output "error_rate_alarm_arn" {
  description = "The ARN of the error rate CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.error_rate[0].arn : null
}

# Security Controls Validation Outputs
output "security_controls_validation" {
  description = "Security controls validation status"
  value = var.security_controls_enabled ? {
    https_enforcement    = local.https_validation
    origin_security     = local.origin_security_validation
    security_headers    = local.security_headers_validation
    geo_restrictions    = local.geo_restriction_validation
    logging_enabled     = local.logging_validation
  } : null
}

# Configuration Summary Outputs
output "distribution_config" {
  description = "Summary of the distribution configuration"
  value = {
    name                    = var.distribution_name
    enabled                 = var.enabled
    price_class            = var.price_class
    ipv6_enabled           = var.is_ipv6_enabled
    default_root_object    = var.default_root_object
    aliases                = var.aliases
    viewer_protocol_policy = var.viewer_protocol_policy
    origins_count          = length(var.origins)
    cache_behaviors_count  = length(var.ordered_cache_behaviors)
    custom_errors_count    = length(var.custom_error_responses)
  }
}

# Security Configuration Summary
output "security_config" {
  description = "Summary of security configuration"
  value = {
    https_enforced           = var.viewer_protocol_policy == "redirect-to-https" || var.viewer_protocol_policy == "https-only"
    waf_enabled             = var.web_acl_id != null
    logging_enabled         = var.enable_logging
    security_headers_enabled = var.enable_security_headers
    geo_restrictions_enabled = var.geo_restriction.restriction_type != "none"
    origin_access_control   = var.create_origin_access_control
    minimum_tls_version     = var.viewer_certificate.minimum_protocol_version
  }
}

# Monitoring Configuration
output "monitoring_config" {
  description = "Summary of monitoring configuration"
  value = {
    cloudwatch_alarms_enabled = var.enable_cloudwatch_alarms
    origin_latency_threshold  = var.origin_latency_threshold
    error_rate_threshold      = var.error_rate_threshold
    alarm_actions_count       = length(var.alarm_actions)
  }
}

# Tags Applied
output "tags_applied" {
  description = "All tags applied to the distribution"
  value       = local.standard_tags
}

# CCMS Compliance Information
output "ccms_compliance" {
  description = "CCMS compliance information"
  value = {
    environment         = var.environment
    project_name       = var.project_name
    owner              = var.owner
    cost_center        = var.cost_center
    business_unit      = var.business_unit
    application_name   = var.application_name
    data_classification = var.data_classification
    security_controls  = "CF-01,CF-02,CF-03,CF-04,CF-05"
    compliance_status  = var.security_controls_enabled ? "ENABLED" : "DISABLED"
  }
}

# URLs and Endpoints
output "distribution_urls" {
  description = "Distribution URLs and endpoints"
  value = {
    cloudfront_domain = aws_cloudfront_distribution.main.domain_name
    cloudfront_url    = "https://${aws_cloudfront_distribution.main.domain_name}"
    aliases_urls      = [for alias in var.aliases : "https://${alias}"]
  }
}

# Origin Information
output "origins_summary" {
  description = "Summary of configured origins"
  value = [
    for origin in var.origins : {
      id          = origin.origin_id
      domain_name = origin.domain_name
      origin_path = origin.origin_path
      type        = origin.s3_origin_config != null ? "S3" : "Custom"
      protocol    = origin.custom_origin_config != null ? origin.custom_origin_config.origin_protocol_policy : "N/A"
    }
  ]
}

# Cache Behaviors Summary
output "cache_behaviors_summary" {
  description = "Summary of cache behaviors"
  value = {
    default_behavior = {
      target_origin_id       = var.default_cache_behavior.target_origin_id
      viewer_protocol_policy = var.viewer_protocol_policy
      compress              = var.default_cache_behavior.compress
      cache_policy_id       = var.default_cache_behavior.cache_policy_id
    }
    ordered_behaviors_count = length(var.ordered_cache_behaviors)
    ordered_behaviors = [
      for behavior in var.ordered_cache_behaviors : {
        path_pattern           = behavior.path_pattern
        target_origin_id       = behavior.target_origin_id
        viewer_protocol_policy = behavior.viewer_protocol_policy
      }
    ]
  }
}