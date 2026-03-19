# AWS S3 Enhanced Terraform Module (L2)

A comprehensive L2 Terraform module for deploying AWS S3 buckets with advanced enterprise features, cross-region replication, backup integration, and enhanced monitoring capabilities.

## Features

- **All L1 Features**: Inherits all security controls and features from the base S3 L1 module
- **Cross-Region Replication**: Automated data replication across AWS regions
- **AWS Backup Integration**: Comprehensive backup and recovery with lifecycle management
- **Storage Analytics**: S3 analytics for storage optimization and cost management
- **Inventory Management**: Automated inventory reports for compliance and auditing
- **Enhanced Monitoring**: CloudWatch dashboards and advanced metric alarms
- **Cost Optimization**: Intelligent tiering and advanced lifecycle management
- **Compliance Automation**: Automated compliance reporting and validation

## Enhanced Security Controls

This L2 module implements additional security controls beyond the L1 module:

- **S3-09**: Cross-Region Replication Security with encryption
- **S3-10**: Advanced Backup and Recovery with AWS Backup
- **S3-11**: Enhanced Monitoring and Alerting with dashboards
- **S3-12**: Storage Analytics and Optimization
- **S3-13**: Compliance and Audit Trail automation

## Usage

### Basic Enhanced Example

```hcl
module "s3_enhanced" {
  source = "./modules/s3-enhanced"

  # Basic configuration
  bucket_name = "my-enterprise-bucket-${random_id.suffix.hex}"
  environment = "prod"

  # Enhanced features
  compliance_mode = "strict"
  
  # Cross-region replication
  enable_cross_region_replication = true
  replication_destination_bucket  = "arn:aws:s3:::my-backup-bucket"
  replication_storage_class      = "STANDARD_IA"

  # AWS Backup integration
  enable_backup = true
  backup_schedule = "cron(0 2 ? * * *)" # Daily at 2 AM
  backup_delete_after = 2555 # 7 years retention

  # Enhanced monitoring
  enable_enhanced_monitoring = true
  bucket_size_alarm_threshold = 107374182400 # 100 GB
  
  # CCMS compliance
  cost_center         = "finance"
  project_name        = "enterprise-data"
  owner              = "data-team"
  business_unit      = "finance"
  application_name   = "data-platform"
  data_classification = "confidential"
}
```

### Full Enterprise Configuration

```hcl
module "enterprise_s3" {
  source = "./modules/s3-enhanced"

  bucket_name = "enterprise-data-lake-${random_id.suffix.hex}"
  environment = "prod"
  compliance_mode = "regulatory"

  # Enhanced security
  encryption_type = "aws:kms"
  kms_key_id     = aws_kms_key.s3_key.arn
  enable_mfa_delete = true

  # Cross-region replication with encryption
  enable_cross_region_replication = true
  replication_destination_bucket  = aws_s3_bucket.replica.arn
  replication_storage_class      = "STANDARD_IA"
  replication_kms_key_id         = aws_kms_key.replica_key.arn

  # Storage analytics and optimization
  enable_analytics = true
  analytics_destination_bucket = aws_s3_bucket.analytics.arn
  analytics_export_prefix     = "storage-analytics/"

  # Inventory management
  enable_inventory = true
  inventory_destination_bucket = aws_s3_bucket.inventory.arn
  inventory_frequency         = "Daily"
  inventory_format           = "Parquet"
  inventory_optional_fields  = [
    "Size", "LastModifiedDate", "StorageClass", 
    "ETag", "IsMultipartUploaded", "ReplicationStatus",
    "EncryptionStatus"
  ]

  # Comprehensive backup strategy
  enable_backup = true
  backup_schedule = "cron(0 1 ? * * *)" # Daily at 1 AM
  backup_kms_key_id = aws_kms_key.backup_key.arn
  backup_cold_storage_after = 30
  backup_delete_after = 2555 # 7 years

  # Enhanced monitoring and alerting
  enable_enhanced_monitoring = true
  bucket_size_alarm_threshold = 1073741824000 # 1 TB
  object_count_alarm_threshold = 10000000 # 10 million objects
  alarm_actions = [aws_sns_topic.alerts.arn]

  # Advanced lifecycle management
  enable_default_lifecycle = true
  transition_to_ia_days = 30
  transition_to_glacier_days = 90
  transition_to_deep_archive_days = 365
  noncurrent_version_expiration_days = 90

  # Custom lifecycle rules
  custom_lifecycle_rules = [
    {
      id     = "archive-old-logs"
      status = "Enabled"
      filter = {
        prefix = "logs/"
      }
      transitions = [
        {
          days          = 7
          storage_class = "STANDARD_IA"
        },
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 2555 # 7 years
      }
    }
  ]

  # Intelligent tiering for cost optimization
  enable_intelligent_tiering = true
  intelligent_tiering_prefix = "data/"
  intelligent_tiering_deep_archive_days = 90

  # Object lock for compliance
  enable_object_lock = true
  object_lock_mode = "COMPLIANCE"
  object_lock_retention_days = 2555 # 7 years

  # CCMS compliance tags
  cost_center         = "compliance"
  project_name        = "regulatory-data-lake"
  owner              = "compliance-team"
  business_unit      = "legal"
  application_name   = "regulatory-platform"
  data_classification = "restricted"
  retention_policy    = "long-term"

  # Additional enterprise tags
  additional_tags = {
    DataLake        = "enterprise"
    BackupEnabled   = "true"
    ReplicationEnabled = "true"
    ComplianceLevel = "regulatory"
    CostCenter      = "compliance"
    BusinessCritical = "true"
  }
}
```

## Enhanced Features

### Cross-Region Replication

Automated replication of objects to another AWS region for disaster recovery:

```hcl
enable_cross_region_replication = true
replication_destination_bucket  = "arn:aws:s3:::backup-bucket"
replication_storage_class      = "STANDARD_IA"
replication_kms_key_id         = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
```

### AWS Backup Integration

Comprehensive backup solution with lifecycle management:

```hcl
enable_backup = true
backup_schedule = "cron(0 2 ? * * *)" # Daily at 2 AM
backup_kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
backup_cold_storage_after = 30  # Move to cold storage after 30 days
backup_delete_after = 365       # Delete after 1 year
```

### Storage Analytics

Automated storage class analysis for cost optimization:

```hcl
enable_analytics = true
analytics_destination_bucket = "arn:aws:s3:::analytics-bucket"
analytics_export_prefix     = "storage-analytics/"
analytics_prefix           = "data/"
analytics_tags = {
  AnalysisType = "storage-optimization"
}
```

### Inventory Management

Automated inventory reports for compliance and auditing:

```hcl
enable_inventory = true
inventory_destination_bucket = "arn:aws:s3:::inventory-bucket"
inventory_frequency         = "Daily"
inventory_format           = "Parquet"
inventory_optional_fields  = [
  "Size", "LastModifiedDate", "StorageClass", 
  "ETag", "IsMultipartUploaded", "ReplicationStatus"
]
```

### Enhanced Monitoring

CloudWatch dashboards and advanced metric alarms:

```hcl
enable_enhanced_monitoring = true
bucket_size_alarm_threshold = 107374182400 # 100 GB
object_count_alarm_threshold = 1000000     # 1 million objects
alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alerts"]
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| environment | Environment name (dev, qa, prod) | `string` | n/a | yes |
| compliance_mode | Compliance mode for enhanced security | `string` | `"standard"` | no |
| enable_cross_region_replication | Enable cross-region replication | `bool` | `false` | no |
| replication_destination_bucket | Destination bucket ARN for replication | `string` | `null` | no |
| enable_analytics | Enable S3 analytics | `bool` | `false` | no |
| enable_inventory | Enable S3 inventory | `bool` | `false` | no |
| enable_backup | Enable AWS Backup | `bool` | `false` | no |
| enable_enhanced_monitoring | Enable enhanced monitoring | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | ID of the S3 bucket |
| bucket_arn | ARN of the S3 bucket |
| enhanced_features_status | Status of enhanced L2 features |
| replication_configuration | Cross-region replication configuration |
| backup_configuration | AWS Backup configuration |
| enhanced_monitoring | Enhanced monitoring configuration |
| operational_summary | Operational summary of the enhanced bucket |

## Cost Optimization

The enhanced module includes several advanced cost optimization features:

- **Advanced Lifecycle Rules**: Automated transition to cheaper storage classes
- **Intelligent Tiering**: ML-based automatic cost optimization
- **Storage Analytics**: Data-driven storage optimization recommendations
- **Cross-Region Optimization**: Optimized replication storage classes
- **Backup Lifecycle**: Automated backup retention and cold storage

## Compliance

This enhanced module supports:

- **Regulatory Compliance**: GDPR, HIPAA, SOX, PCI DSS
- **Enterprise Governance**: Advanced tagging and resource management
- **Audit Requirements**: Comprehensive logging and inventory
- **Data Residency**: Cross-region replication with compliance controls
- **Retention Policies**: Automated lifecycle and backup retention

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| random | >= 3.1 |
| null | >= 3.0 |

## Dependencies

This L2 module depends on:
- **S3 L1 Module**: `../s3-module` (base functionality)
- **AWS Backup**: For backup integration
- **CloudWatch**: For enhanced monitoring
- **KMS**: For advanced encryption features

## Examples

The module includes several examples:

- **basic-enhanced/**: Basic L2 configuration
- **enterprise/**: Full enterprise configuration
- **compliance/**: Regulatory compliance configuration
- **disaster-recovery/**: Multi-region disaster recovery setup

## Migration from L1

To migrate from the L1 module to L2:

1. Update the module source path
2. Add enhanced feature configurations
3. Review and update compliance settings
4. Test in non-production environment first

## Support

For issues and questions:

1. Check the examples directory
2. Review the L1 module documentation
3. Validate enhanced feature requirements
4. Ensure proper IAM permissions for advanced features

## Changelog

### Version 1.0.0
- Initial L2 enhanced module release
- Cross-region replication support
- AWS Backup integration
- Storage analytics and inventory
- Enhanced monitoring with dashboards
- Advanced lifecycle management
- Compliance automation features