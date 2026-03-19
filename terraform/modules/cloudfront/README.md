# AWS CloudFront Terraform Module

A comprehensive Terraform module for creating and managing AWS CloudFront distributions with enterprise-grade security controls, monitoring, and CCMS compliance.

## Features

### Core Features
- ✅ CloudFront Distribution with multiple origins support
- ✅ Origin Access Control (OAC) for S3 origins
- ✅ Custom cache behaviors and policies
- ✅ SSL/TLS configuration with ACM integration
- ✅ Custom error pages and responses
- ✅ Geographic restrictions
- ✅ Lambda@Edge and CloudFront Functions support

### Security Features
- 🔒 **CF-01: HTTPS Enforcement** - Automatic HTTPS redirect/enforcement
- 🔒 **CF-02: Origin Security** - Secure origin communication with OAC
- 🔒 **CF-03: Security Headers** - Comprehensive security headers policy
- 🔒 **CF-04: Geographic Access Control** - Country-based access restrictions
- 🔒 **CF-05: Access Logging** - Comprehensive access logging to S3

### Monitoring & Compliance
- 📊 CloudWatch alarms for latency and error rates
- 📋 CCMS compliance with standardized tagging
- 🔍 Security controls validation
- 📈 Cost optimization features

## Usage

### Basic S3 Website Distribution

```hcl
module "cloudfront_website" {
  source = "./modules/cloudfront"

  # Basic Configuration
  distribution_name = "my-website-cdn"
  comment          = "CDN for my static website"
  
  # CCMS Required Tags
  environment      = "prod"
  project_name     = "my-project"
  owner           = "team@company.com"
  cost_center     = "engineering"
  business_unit   = "technology"
  application_name = "my-website"

  # Origins
  origins = [{
    domain_name = "my-bucket.s3.amazonaws.com"
    origin_id   = "S3-my-bucket"
    origin_path = ""
    use_origin_access_control = true
    s3_origin_config = null
    custom_origin_config = null
    custom_headers = []
    origin_shield = null
  }]

  # Default Cache Behavior
  default_cache_behavior = {
    target_origin_id = "S3-my-bucket"
    compress        = true
    cache_policy_id = "managed-caching-optimized"
  }

  # Security
  viewer_protocol_policy = "redirect-to-https"
  enable_security_headers = true
  
  # Origin Access Control
  create_origin_access_control = true
}
```

### Multi-Origin Distribution with API

```hcl
module "cloudfront_multi_origin" {
  source = "./modules/cloudfront"

  distribution_name = "multi-origin-cdn"
  comment          = "CDN with S3 and API origins"
  
  # CCMS Tags
  environment      = "prod"
  project_name     = "my-app"
  owner           = "devops@company.com"
  cost_center     = "engineering"
  business_unit   = "technology"
  application_name = "my-app"

  # Multiple Origins
  origins = [
    {
      domain_name = "my-bucket.s3.amazonaws.com"
      origin_id   = "S3-static"
      use_origin_access_control = true
    },
    {
      domain_name = "api.example.com"
      origin_id   = "API-backend"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  # Default behavior for static content
  default_cache_behavior = {
    target_origin_id = "S3-static"
    cache_policy_id  = "managed-caching-optimized"
  }

  # API cache behavior
  ordered_cache_behaviors = [{
    path_pattern           = "/api/*"
    target_origin_id       = "API-backend"
    viewer_protocol_policy = "https-only"
    cache_policy_id        = "managed-caching-disabled"
    origin_request_policy_id = "managed-cors-s3-origin"
  }]

  # Custom SSL Certificate
  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = ["cdn.example.com", "assets.example.com"]

  # Security Features
  enable_security_headers = true
  enable_logging         = true
  logging_config = {
    bucket = "my-cloudfront-logs.s3.amazonaws.com"
    prefix = "cloudfront-logs/"
  }

  # Monitoring
  enable_cloudwatch_alarms = true
  origin_latency_threshold = 1000
  error_rate_threshold    = 5
}
```

### Enterprise Security Configuration

```hcl
module "cloudfront_enterprise" {
  source = "./modules/cloudfront"

  distribution_name = "enterprise-cdn"
  comment          = "Enterprise CDN with full security controls"
  
  # CCMS Tags
  environment         = "prod"
  project_name        = "enterprise-app"
  owner              = "security@company.com"
  cost_center        = "security"
  business_unit      = "technology"
  application_name   = "enterprise-portal"
  data_classification = "confidential"

  # Origins with security
  origins = [{
    domain_name = "secure-bucket.s3.amazonaws.com"
    origin_id   = "S3-secure"
    use_origin_access_control = true
  }]

  default_cache_behavior = {
    target_origin_id           = "S3-secure"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers[0].id
  }

  # Full Security Controls
  security_controls_enabled = true
  viewer_protocol_policy   = "https-only"
  enable_security_headers  = true
  
  # Security Headers Configuration
  security_headers = {
    frame_options              = "DENY"
    referrer_policy           = "strict-origin-when-cross-origin"
    content_security_policy   = "default-src 'self'; script-src 'self' 'unsafe-inline'"
    hsts_max_age             = 31536000
    hsts_include_subdomains  = true
    hsts_preload             = true
  }

  # Geographic Restrictions
  geo_restriction = {
    restriction_type = "whitelist"
    locations       = ["US", "CA", "GB", "DE", "FR"]
  }

  # WAF Integration
  web_acl_id = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/example/12345678-1234-1234-1234-123456789012"

  # Comprehensive Logging
  enable_logging = true
  logging_config = {
    bucket          = "security-logs.s3.amazonaws.com"
    prefix          = "cloudfront-access-logs/"
    include_cookies = true
  }

  # Monitoring and Alerting
  enable_cloudwatch_alarms = true
  origin_latency_threshold = 500
  error_rate_threshold    = 2
  alarm_actions          = ["arn:aws:sns:us-east-1:123456789012:security-alerts"]

  # Custom Error Pages
  custom_error_responses = [
    {
      error_code         = 403
      response_code      = 403
      response_page_path = "/errors/403.html"
    },
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/errors/404.html"
    }
  ]
}
```

## Security Controls

### CF-01: HTTPS Enforcement
Ensures all viewer requests use HTTPS for data protection in transit.

**Implementation:**
- `viewer_protocol_policy = "redirect-to-https"` or `"https-only"`
- Automatic validation in module

**Validation:**
```hcl
# Automatically validated - check outputs
output "https_status" {
  value = module.cloudfront.security_controls_validation.https_enforcement
}
```

### CF-02: Origin Security
Secures communication between CloudFront and origins.

**Implementation:**
- Origin Access Control (OAC) for S3 origins
- HTTPS-only origin protocol policy for custom origins
- Proper S3 bucket policies

**Example:**
```hcl
create_origin_access_control = true
origins = [{
  custom_origin_config = {
    origin_protocol_policy = "https-only"
  }
}]
```

### CF-03: Security Headers
Implements comprehensive security headers for enhanced protection.

**Implementation:**
- Response Headers Policy with HSTS, CSP, X-Frame-Options
- Configurable security headers
- CORS support

**Example:**
```hcl
enable_security_headers = true
security_headers = {
  frame_options              = "DENY"
  content_security_policy   = "default-src 'self'"
  hsts_max_age             = 31536000
}
```

### CF-04: Geographic Access Control
Controls access based on geographic location.

**Implementation:**
- Configurable geo-restriction policies
- Whitelist/blacklist support
- Country-code based restrictions

**Example:**
```hcl
geo_restriction = {
  restriction_type = "whitelist"
  locations       = ["US", "CA", "GB"]
}
```

### CF-05: Access Logging
Enables comprehensive access logging for security monitoring.

**Implementation:**
- CloudFront access logs to S3
- Configurable log format and location
- Cookie logging support

**Example:**
```hcl
enable_logging = true
logging_config = {
  bucket          = "my-logs.s3.amazonaws.com"
  prefix          = "cloudfront/"
  include_cookies = true
}
```

## Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `distribution_name` | Name for the CloudFront distribution | `string` |
| `environment` | Environment name (dev, staging, prod) | `string` |
| `project_name` | Name of the project | `string` |
| `owner` | Owner of the resources | `string` |
| `cost_center` | Cost center for billing | `string` |
| `business_unit` | Business unit | `string` |
| `application_name` | Name of the application | `string` |
| `origins` | List of origins for the distribution | `list(object)` |
| `default_cache_behavior` | Default cache behavior configuration | `object` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `comment` | Comment for the distribution | `string` | `""` |
| `enabled` | Whether the distribution is enabled | `bool` | `true` |
| `price_class` | Price class for the distribution | `string` | `"PriceClass_All"` |
| `aliases` | Alternate domain names (CNAMEs) | `list(string)` | `[]` |
| `viewer_protocol_policy` | Protocol policy for viewers | `string` | `"redirect-to-https"` |
| `enable_security_headers` | Enable security headers | `bool` | `true` |
| `enable_logging` | Enable access logging | `bool` | `false` |
| `enable_cloudwatch_alarms` | Enable CloudWatch alarms | `bool` | `false` |

See [variables.tf](./variables.tf) for complete list of variables.

## Outputs

### Primary Outputs

| Name | Description |
|------|-------------|
| `distribution_id` | The identifier for the distribution |
| `distribution_arn` | The ARN for the distribution |
| `distribution_domain_name` | The domain name of the distribution |
| `distribution_status` | The current status of the distribution |

### Security Outputs

| Name | Description |
|------|-------------|
| `security_controls_validation` | Security controls validation status |
| `security_config` | Summary of security configuration |
| `origin_access_control_id` | Origin Access Control ID |

### Monitoring Outputs

| Name | Description |
|------|-------------|
| `monitoring_config` | Summary of monitoring configuration |
| `origin_latency_alarm_arn` | Origin latency alarm ARN |
| `error_rate_alarm_arn` | Error rate alarm ARN |

See [outputs.tf](./outputs.tf) for complete list of outputs.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| null | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| null | ~> 3.0 |

## Cost Considerations

### Pricing Factors
- **Data Transfer Out**: Varies by region and volume
- **HTTP/HTTPS Requests**: Per 10,000 requests
- **Price Class**: Affects edge location coverage
- **Origin Requests**: Requests forwarded to origin
- **Lambda@Edge**: Function invocations and duration
- **Real-time Logs**: Additional cost for real-time logging

### Cost Optimization Tips
1. Choose appropriate price class based on audience
2. Optimize cache behaviors and TTL values
3. Use compression to reduce data transfer
4. Monitor and optimize cache hit rates
5. Consider Origin Shield for high-traffic origins

## Best Practices

### Security
- Always use HTTPS redirect or HTTPS-only
- Implement Origin Access Control for S3 origins
- Enable security headers for web applications
- Use WAF for additional protection
- Configure appropriate geographic restrictions
- Enable access logging for security monitoring

### Performance
- Choose appropriate price class for your audience
- Configure cache behaviors properly
- Use compression for text-based content
- Set appropriate TTL values
- Consider Origin Shield for popular content
- Monitor cache hit rates

### Monitoring
- Enable CloudWatch alarms for key metrics
- Monitor origin latency and error rates
- Use real-time logs for debugging
- Set up appropriate alarm thresholds
- Monitor cost and usage patterns

### Compliance
- Follow CCMS tagging standards
- Enable all security controls for production
- Document security configurations
- Regular security reviews
- Maintain compliance evidence

## Troubleshooting

### Common Issues

#### Distribution Not Updating
**Cause**: CloudFront propagation delay
**Solution**: Wait for deployment completion, check `wait_for_deployment` setting

#### Origin Access Denied
**Cause**: Incorrect Origin Access Control configuration
**Solution**: Verify OAC settings and S3 bucket policy

#### SSL Certificate Errors
**Cause**: Certificate not in us-east-1 or validation issues
**Solution**: Ensure ACM certificate is in us-east-1 and validated

#### Cache Not Working
**Cause**: Incorrect cache behavior configuration
**Solution**: Review cache policies and TTL settings

### Validation Commands

```bash
# Check distribution status
aws cloudfront get-distribution --id <distribution-id>

# Test HTTPS redirect
curl -I http://your-domain.com

# Verify security headers
curl -I https://your-domain.com

# Check cache behavior
curl -I https://your-domain.com/path
```

## Migration Guide

### From Legacy Configurations

#### Origin Access Identity → Origin Access Control
```hcl
# Old (deprecated)
s3_origin_config = {
  origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
}

# New (recommended)
create_origin_access_control = true
use_origin_access_control = true
```

#### Forwarded Values → Cache Policies
```hcl
# Old (legacy)
forwarded_values = {
  query_string = true
  headers      = ["Host"]
}

# New (recommended)
cache_policy_id = "managed-caching-optimized"
```

### Migration Considerations
- Plan for propagation delays (15-20 minutes)
- Test thoroughly in non-production environments
- Update DNS gradually using weighted routing
- Monitor performance during migration
- Have rollback plan ready

## Examples

See the [examples](./examples/) directory for complete working examples:
- [Basic S3 Website](./examples/basic-s3-website/)
- [Multi-Origin Distribution](./examples/multi-origin/)
- [Enterprise Security](./examples/enterprise-security/)
- [API Acceleration](./examples/api-acceleration/)

## Contributing

1. Follow the module structure and naming conventions
2. Update documentation for any changes
3. Add examples for new features
4. Test with multiple scenarios
5. Ensure security controls validation works

## License

This module is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the IndraSuite Infrastructure Team
- Check the troubleshooting section above

---

**Note**: This module implements enterprise-grade security controls and CCMS compliance. Ensure you understand the security implications and cost considerations before deployment.