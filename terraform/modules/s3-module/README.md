# AWS S3 Terraform Module

A comprehensive Terraform module for deploying AWS S3 buckets with enterprise-grade security controls, CCMS compliance, and monitoring capabilities.

## Features

- **Security Controls**: 8 built-in security controls including server-side encryption, versioning, and public access blocking
- **CCMS Compliance**: Full compliance with Cloud Configuration Management Standards
- **Monitoring**: CloudWatch monitoring and custom alarms for security events
- **Lifecycle Management**: Automated object lifecycle and cost optimization
- **Flexibility**: Extensive configuration options for all S3 features
- **Validation**: Built-in validation for security and compliance requirements

## Security Controls

This module implements the following security controls:

- **S3-01**: Server-Side Encryption at Rest
- **S3-02**: Object Versioning and MFA Delete
- **S3-03**: Public Access Block Configuration
- **S3-04**: SSL-Only Access Enforcement
- **S3-05**: Access Logging and Audit Trail
- **S3-06**: Lifecycle Management and Cost Optimization
- **S3-07**: Object Lock for Compliance
- **S3-08**: CloudWatch Security Monitoring

## Usage

### Basic Example

```hcl
module "s3_bucket" {
  source = "./modules/s3-module"

  # Required variables
  bucket_name = "my-secure-bucket-${random_id.bucket_suffix.hex}"
  environment = "prod"

  # Security configuration
  require_encryption    = true
  encryption_type      = "AES256"
  enable_versioning    = true
  block_public_access  = true
  enable_ssl_only      = true

  # Monitoring
  enable_cloudwatch_monitoring = true

  # CCMS compliance
  cost_center         = "engineering"
  project_name        = "data-platform"
  owner              = "platform-team"
  business_unit      = "engineering"
  application_name   = "data-storage"
  data_classification = "confidential"
}
```

### Advanced Example with KMS Encryption

```hcl
module "secure_s3_bucket" {
  source = "./modules/s3-module"

  bucket_name = "enterprise-data-bucket-${random_id.bucket_suffix.hex}"
  environment = "prod"

  # Advanced security configuration
  require_encryption    = true
  encryption_type      = "aws:kms"
  kms_key_id          = aws_kms_key.s3_key.arn
  bucket_key_enabled   = true
  
  enable_versioning    = true
  enable_mfa_delete    = true
  block_public_access  = true
  enable_ssl_only      = true

  # Access logging
  enable_access_logging = true
  access_log_bucket    = "my-access-logs-bucket"
  access_log_prefix    = "s3-access-logs/"

  # Lifecycle management
  lifecycle_rules = [
    {
      id     = "transition_to_ia"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      noncurrent_version_transitions = [
        {
          noncurrent_days = 30
          storage_class   = "STANDARD_IA"
        }
      ]
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]

  # Object lock for compliance
  enable_object_lock           = true
  object_lock_mode            = "COMPLIANCE"
  object_lock_retention_days  = 2555  # 7 years

  # Monitoring and alerting
  enable_cloudwatch_monitoring = true
  alarm_actions               = [aws_sns_topic.alerts.arn]

  # CCMS compliance tags
  cost_center         = "finance"
  project_name        = "compliance-data"
  owner              = "compliance-team"
  business_unit      = "finance"
  application_name   = "regulatory-storage"
  data_classification = "restricted"
  retention_policy    = "long-term"

  # Additional tags
  additional_tags = {
    Backup        = "daily"
    Monitoring    = "enhanced"
    Purpose       = "compliance-data"
    Retention     = "7-years"
  }
}
```

### Website Hosting Example

```hcl
module "website_bucket" {
  source = "./modules/s3-module"

  bucket_name = "my-website-${random_id.bucket_suffix.hex}"
  environment = "prod"

  # Website hosting configuration
  enable_website_hosting   = true
  website_index_document  = "index.html"
  website_error_document  = "404.html"

  # CORS configuration for web assets
  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com", "https://www.example.com"]
      allowed_headers = ["*"]
      max_age_seconds = 3600
    }
  ]

  # Public access for website (carefully configured)
  block_public_access = false
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::my-website-${random_id.bucket_suffix.hex}/*"
      }
    ]
  })

  # Still enforce SSL
  enable_ssl_only = true

  # Basic security
  require_encryption = true
  enable_versioning  = true

  # CCMS compliance
  cost_center         = "marketing"
  project_name        = "corporate-website"
  owner              = "web-team"
  business_unit      = "marketing"
  application_name   = "website"
  data_classification = "public"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| environment | Environment name (dev, qa, prod) | `string` | n/a | yes |
| require_encryption | Whether to require encryption for all objects | `bool` | `true` | no |
| encryption_type | Server-side encryption algorithm | `string` | `"AES256"` | no |
| kms_key_id | KMS key ID for encryption | `string` | `null` | no |
| enable_versioning | Enable versioning for the S3 bucket | `bool` | `true` | no |
| block_public_access | Whether to block all public access | `bool` | `true` | no |
| enable_ssl_only | Whether to enforce SSL-only access | `bool` | `true` | no |
| enable_access_logging | Enable access logging | `bool` | `false` | no |
| access_log_bucket | Target bucket for access logs | `string` | `null` | no |
| lifecycle_rules | List of lifecycle rules | `list(object)` | `[]` | no |
| enable_object_lock | Enable object lock | `bool` | `false` | no |
| enable_cloudwatch_monitoring | Enable CloudWatch monitoring | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | ID of the S3 bucket |
| bucket_arn | ARN of the S3 bucket |
| bucket_domain_name | Domain name of the S3 bucket |
| bucket_regional_domain_name | Regional domain name of the S3 bucket |
| security_controls_status | Status of implemented security controls |
| encryption_details | Detailed encryption configuration |
| compliance_status | Overall compliance status |

## Examples

The module includes several examples:

- **basic/**: Minimal secure configuration
- **advanced/**: Full enterprise configuration with KMS
- **website/**: Static website hosting configuration
- **compliance/**: Regulatory compliance configuration

## Security Considerations

1. **Encryption**: All objects are encrypted by default using AES256 or KMS
2. **Versioning**: Object versioning is enabled by default for data protection
3. **Public Access**: Public access is blocked by default
4. **SSL Only**: HTTPS-only access is enforced by default
5. **Access Logging**: Can be enabled for audit trails
6. **Object Lock**: Available for compliance and immutability requirements
7. **Monitoring**: CloudWatch monitoring for security events

## Compliance

This module is designed to meet:

- AWS Security Best Practices
- CCMS (Cloud Configuration Management Standards)
- SOC 2 Type II requirements
- PCI DSS compliance (when properly configured)
- GDPR data protection requirements
- Enterprise security policies

## Cost Optimization

The module includes several cost optimization features:

- **Lifecycle Rules**: Automatic transition to cheaper storage classes
- **Intelligent Tiering**: Automatic cost optimization based on access patterns
- **Incomplete Multipart Upload Cleanup**: Prevents storage costs from failed uploads
- **Noncurrent Version Management**: Automatic cleanup of old object versions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| random | >= 3.1 |
| null | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| random | >= 3.1 |
| null | >= 3.0 |

## License

This module is provided under the MIT License.

## Support

For issues and questions:

1. Check the examples directory for common use cases
2. Review the security controls documentation
3. Validate your configuration against the input requirements
4. Ensure proper IAM permissions are configured

## Changelog

### Version 1.0.0
- Initial release with comprehensive S3 security controls
- CCMS compliance implementation
- CloudWatch monitoring integration
- Lifecycle management features
- Object lock support
- Website hosting capabilities