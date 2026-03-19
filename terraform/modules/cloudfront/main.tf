}

# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-cloudfront-module"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
    LastModified  = formatdate("YYYY-MM-DD", timestamp())
    CostCenter    = var.cost_center
    Project       = var.project_name
    Owner         = var.owner
    BusinessUnit  = var.business_unit
    Application   = var.application_name
    DataClass     = var.data_classification
    Compliance    = "CCMS"
  }
}

# Local implementation of config validation
locals {
  # Configuration constants and validation
  config = {
    # Security requirements by environment
    security_requirements = {
      https_required          = var.environment == "prod" ? true : var.require_https
      waf_required           = var.environment == "prod" ? true : var.enable_waf
      logging_required       = var.environment == "prod" ? true : var.enable_logging
      security_headers       = var.environment == "prod" ? true : var.enable_security_headers
    }
  }
}

# Standard tags following CCMS requirements with Security Controls
locals {
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.distribution_name
      Module      = "terraform-aws-l1-cloudfront"
      Environment = var.environment
      Component   = "cloudfront-distribution"
      # Security Control CF-01: HTTPS Enforcement
      SecurityControls         = "CF-01,CF-02,CF-03,CF-04,CF-05"
      HTTPSEnforced           = var.viewer_protocol_policy == "redirect-to-https" ? "true" : "false"
      WAFEnabled              = var.web_acl_id != null ? "true" : "false"
      LoggingEnabled          = var.enable_logging ? "true" : "false"
      SecurityHeadersEnabled  = var.enable_security_headers ? "true" : "false"
    },
    var.security_compliance_tags,
    var.additional_tags
  )
}

# CloudFront Origin Access Control (OAC) for S3 origins
resource "aws_cloudfront_origin_access_control" "main" {
  count = var.create_origin_access_control ? 1 : 0

  name                              = "${var.distribution_name}-oac"
  description                       = "Origin Access Control for ${var.distribution_name}"
  origin_access_control_origin_type = var.origin_access_control_origin_type
  signing_behavior                  = var.origin_access_control_signing_behavior
  signing_protocol                  = var.origin_access_control_signing_protocol
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  web_acl_id          = var.web_acl_id

  # Origins (Security Control CF-02: Origin Security)
  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id
      origin_path              = origin.value.origin_path
      connection_attempts      = origin.value.connection_attempts
      connection_timeout       = origin.value.connection_timeout

      # S3 Origin Configuration
      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      # Origin Access Control
      origin_access_control_id = origin.value.origin_access_control_id != null ? origin.value.origin_access_control_id : (
        var.create_origin_access_control && origin.value.use_origin_access_control ? aws_cloudfront_origin_access_control.main[0].id : null
      )

      # Custom Origin Configuration
      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      # Custom Headers
      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      # Origin Shield
      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  # Default Cache Behavior (Security Control CF-01: HTTPS Enforcement)
  default_cache_behavior {
    target_origin_id       = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    compress               = var.default_cache_behavior.compress
    field_level_encryption_id = var.default_cache_behavior.field_level_encryption_id

    # Cache Policy
    cache_policy_id = var.default_cache_behavior.cache_policy_id

    # Origin Request Policy
    origin_request_policy_id = var.default_cache_behavior.origin_request_policy_id

    # Response Headers Policy (Security Control CF-03: Security Headers)
    response_headers_policy_id = var.enable_security_headers ? var.default_cache_behavior.response_headers_policy_id : null

    # Real-time Log Config
    realtime_log_config_arn = var.default_cache_behavior.realtime_log_config_arn

    # Trusted Key Groups
    trusted_key_groups = var.default_cache_behavior.trusted_key_groups

    # Trusted Signers
    trusted_signers = var.default_cache_behavior.trusted_signers

    # Lambda Function Associations
    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_associations
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }

    # CloudFront Functions
    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_associations
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }

    # Forwarded Values (Legacy - use cache policies instead)
    dynamic "forwarded_values" {
      for_each = var.default_cache_behavior.use_forwarded_values ? [var.default_cache_behavior.forwarded_values] : []
      content {
        query_string = forwarded_values.value.query_string
        headers      = forwarded_values.value.headers

        cookies {
          forward           = forwarded_values.value.cookies.forward
          whitelisted_names = forwarded_values.value.cookies.whitelisted_names
        }
      }
    }

    min_ttl     = var.default_cache_behavior.min_ttl
    default_ttl = var.default_cache_behavior.default_ttl
    max_ttl     = var.default_cache_behavior.max_ttl
  }

  # Ordered Cache Behaviors
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress
      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id

      # Cache Policy
      cache_policy_id = ordered_cache_behavior.value.cache_policy_id

      # Origin Request Policy
      origin_request_policy_id = ordered_cache_behavior.value.origin_request_policy_id

      # Response Headers Policy
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id

      # Real-time Log Config
      realtime_log_config_arn = ordered_cache_behavior.value.realtime_log_config_arn

      # Trusted Key Groups
      trusted_key_groups = ordered_cache_behavior.value.trusted_key_groups

      # Trusted Signers
      trusted_signers = ordered_cache_behavior.value.trusted_signers

      # Lambda Function Associations
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_associations
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }

      # CloudFront Functions
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_associations
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      # Forwarded Values (Legacy)
      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.use_forwarded_values ? [ordered_cache_behavior.value.forwarded_values] : []
        content {
          query_string = forwarded_values.value.query_string
          headers      = forwarded_values.value.headers

          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = forwarded_values.value.cookies.whitelisted_names
          }
        }
      }

      min_ttl     = ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl
    }
  }

  # Custom Error Responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # Geographic Restrictions (Security Control CF-04: Geographic Access Control)
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  # SSL/TLS Configuration (Security Control CF-01: HTTPS Enforcement)
  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate.acm_certificate_arn
    cloudfront_default_certificate = var.viewer_certificate.cloudfront_default_certificate
    iam_certificate_id             = var.viewer_certificate.iam_certificate_id
    minimum_protocol_version       = var.viewer_certificate.minimum_protocol_version
    ssl_support_method             = var.viewer_certificate.ssl_support_method
  }

  # Logging Configuration (Security Control CF-05: Access Logging)
  dynamic "logging_config" {
    for_each = var.enable_logging ? [var.logging_config] : []
    content {
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
      include_cookies = logging_config.value.include_cookies
    }
  }

  # Aliases
  aliases = var.aliases

  tags = local.standard_tags
}

# CloudFront Response Headers Policy for Security Headers
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  count = var.create_security_headers_policy ? 1 : 0

  name    = "${var.distribution_name}-security-headers"
  comment = "Security headers policy for ${var.distribution_name}"

  # Security Headers Configuration (Security Control CF-03: Security Headers)
  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = var.security_headers.frame_options
      override     = true
    }

    referrer_policy {
      referrer_policy = var.security_headers.referrer_policy
      override        = true
    }

    strict_transport_security {
      access_control_max_age_sec = var.security_headers.hsts_max_age
      include_subdomains         = var.security_headers.hsts_include_subdomains
      preload                    = var.security_headers.hsts_preload
      override                   = true
    }

    content_security_policy {
      content_security_policy = var.security_headers.content_security_policy
      override                = true
    }
  }

  # CORS Configuration
  dynamic "cors_config" {
    for_each = var.cors_config != null ? [var.cors_config] : []
    content {
      access_control_allow_credentials = cors_config.value.access_control_allow_credentials

      access_control_allow_headers {
        items = cors_config.value.access_control_allow_headers
      }

      access_control_allow_methods {
        items = cors_config.value.access_control_allow_methods
      }

      access_control_allow_origins {
        items = cors_config.value.access_control_allow_origins
      }

      access_control_expose_headers {
        items = cors_config.value.access_control_expose_headers
      }

      access_control_max_age_sec = cors_config.value.access_control_max_age_sec
      origin_override           = cors_config.value.origin_override
    }
  }

  # Custom Headers
  dynamic "custom_headers_config" {
    for_each = length(var.custom_headers) > 0 ? [1] : []
    content {
      dynamic "items" {
        for_each = var.custom_headers
        content {
          header   = items.value.header
          value    = items.value.value
          override = items.value.override
        }
      }
    }
  }
}

# CloudWatch Alarms for CloudFront Monitoring
resource "aws_cloudwatch_metric_alarm" "origin_latency" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.distribution_name}-origin-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "OriginLatency"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = var.origin_latency_threshold
  alarm_description   = "This metric monitors CloudFront origin latency"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "CF_05_Monitoring"
      AlarmType       = "origin_latency"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.distribution_name}-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = var.error_rate_threshold
  alarm_description   = "This metric monitors CloudFront 4xx error rate"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "CF_05_Monitoring"
      AlarmType       = "error_rate"
    }
  )
}

# Security Control Validation - Local values for validation
locals {
  # Security Control CF-01: Validate HTTPS enforcement
  https_validation = var.security_controls_enabled ? (
    var.viewer_protocol_policy == "redirect-to-https" || var.viewer_protocol_policy == "https-only" ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control CF-02: Validate origin security
  origin_security_validation = var.security_controls_enabled ? (
    alltrue([
      for origin in var.origins :
      origin.custom_origin_config != null ? origin.custom_origin_config.origin_protocol_policy == "https-only" : true
    ]) ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control CF-03: Validate security headers
  security_headers_validation = var.enable_security_headers ? (
    var.create_security_headers_policy || var.default_cache_behavior.response_headers_policy_id != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control CF-04: Validate geographic restrictions
  geo_restriction_validation = var.security_controls_enabled ? (
    var.geo_restriction.restriction_type != "none" ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control CF-05: Validate logging
  logging_validation = var.enable_logging ? (
    var.logging_config.bucket != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"
}

# Security Control Validation Output
resource "null_resource" "security_controls_validation" {
  count = var.security_controls_enabled ? 1 : 0

  triggers = {
    https_status           = local.https_validation
    origin_security_status = local.origin_security_validation
    security_headers_status = local.security_headers_validation
    geo_restriction_status = local.geo_restriction_validation
    logging_status         = local.logging_validation
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "CloudFront Security Controls Validation Report:"
      echo "CF-01 HTTPS Enforcement: ${local.https_validation}"
      echo "CF-02 Origin Security: ${local.origin_security_validation}"
      echo "CF-03 Security Headers: ${local.security_headers_validation}"
      echo "CF-04 Geographic Restrictions: ${local.geo_restriction_validation}"
      echo "CF-05 Logging: ${local.logging_validation}"
    EOT
  }
}