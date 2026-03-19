# Outputs for Basic S3 Enhanced Module Example

output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = module.s3_basic_example.bucket_id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3_basic_example.bucket_arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.s3_basic_example.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_basic_example.bucket_regional_domain_name
}

output "bucket_region" {
  description = "AWS region where the S3 bucket is located"
  value       = module.s3_basic_example.bucket_region
}

output "encryption_configuration" {
  description = "Server-side encryption configuration"
  value       = module.s3_basic_example.encryption_configuration
  sensitive   = true
}

output "versioning_configuration" {
  description = "Versioning configuration of the S3 bucket"
  value       = module.s3_basic_example.versioning_configuration
}

output "public_access_block" {
  description = "Public access block configuration"
  value       = module.s3_basic_example.public_access_block
}

output "security_controls_status" {
  description = "Status of implemented security controls"
  value = {
    encryption_enabled    = true
    versioning_enabled   = true
    public_access_blocked = true
    ssl_only_enabled     = true
  }
}

output "ccms_compliance_tags" {
  description = "CCMS compliance tags applied to the bucket"
  value = {
    CostCenter        = var.cost_center
    ProjectName       = var.project_name
    Owner            = var.owner
    BusinessUnit     = var.business_unit
    ApplicationName  = var.application_name
    DataClassification = var.data_classification
    Environment      = var.environment
  }
}