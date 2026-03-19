# Unit Tests for S3 Enhanced Module
# Tests individual module logic in isolation with mocks

# Mock provider for credential-free testing
mock_provider "aws" {
  # Mock S3 bucket resource
  mock_resource "aws_s3_bucket" {
    defaults = {
      id                          = "test-bucket-12345"
      arn                         = "arn:aws:s3:::test-bucket-12345"
      bucket                      = "test-bucket-12345"
      bucket_domain_name          = "test-bucket-12345.s3.amazonaws.com"
      bucket_regional_domain_name = "test-bucket-12345.s3.us-east-1.amazonaws.com"
      hosted_zone_id             = "Z3AQBSTGFYJSTF"
      region                     = "us-east-1"
      tags_all = {
        Name               = "test-bucket-12345"
        Environment        = "test"
        Module             = "terraform-aws-l2-s3-enhanced"
        Layer              = "L2"
        CostCenter         = "engineering"
        ProjectName        = "test-project"
        Owner              = "test-team"
        BusinessUnit       = "engineering"
        ApplicationName    = "test-app"
        DataClassification = "internal"
      }
    }
  }

  # Mock S3 bucket encryption
  mock_resource "aws_s3_bucket_server_side_encryption_configuration" {
    defaults = {
      bucket = "test-bucket-12345"
      rule = [{
        apply_server_side_encryption_by_default = [{
          sse_algorithm = "AES256"
        }]
        bucket_key_enabled = true
      }]
    }
  }

  # Mock S3 bucket versioning
  mock_resource "aws_s3_bucket_versioning" {
    defaults = {
      bucket = "test-bucket-12345"
      versioning_configuration = [{
        status = "Enabled"
      }]
    }
  }

  # Mock S3 bucket public access block
  mock_resource "aws_s3_bucket_public_access_block" {
    defaults = {
      bucket                  = "test-bucket-12345"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }

  # Mock S3 bucket policy
  mock_resource "aws_s3_bucket_policy" {
    defaults = {
      bucket = "test-bucket-12345"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid       = "DenyInsecureConnections"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource = [
            "arn:aws:s3:::test-bucket-12345",
            "arn:aws:s3:::test-bucket-12345/*"
          ]
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        }]
      })
    }
  }
}

# Test basic bucket creation with minimal configuration
run "test_basic_bucket_creation" {
  command = plan

  variables {
    bucket_name         = "test-bucket-basic"
    environment         = "test"
    cost_center        = "engineering"
    project_name       = "test-project"
    owner             = "test-team"
    business_unit     = "engineering"
    application_name  = "test-app"
    data_classification = "internal"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "test-bucket-basic"
    error_message = "S3 bucket name should match the input variable"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "test"
    error_message = "Environment tag should be set correctly"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Module"] == "terraform-aws-l2-s3-enhanced"
    error_message = "Module tag should be set correctly"
  }
}

# Test encryption configuration
run "test_encryption_configuration" {
  command = plan

  variables {
    bucket_name         = "test-bucket-encryption"
    environment         = "test"
    encryption_type     = "AES256"
    cost_center        = "engineering"
    project_name       = "test-project"
    owner             = "test-team"
    business_unit     = "engineering"
    application_name  = "test-app"
    data_classification = "internal"
  }

  assert {
    condition = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Encryption should be configured with AES256"
  }

  assert {
    condition = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].bucket_key_enabled == true
    error_message = "Bucket key should be enabled by default"
  }
}

# Test versioning configuration
run "test_versioning_configuration" {
  command = plan

  variables {
    bucket_name         = "test-bucket-versioning"
    environment         = "test"
    enable_versioning   = true
    versioning_status   = "Enabled"
    cost_center        = "engineering"
    project_name       = "test-project"
    owner             = "test-team"
    business_unit     = "engineering"
    application_name  = "test-app"
    data_classification = "internal"
  }

  assert {
    condition = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled when requested"
  }
}

# Test public access block configuration
run "test_public_access_block" {
  command = plan

  variables {
    bucket_name         = "test-bucket-public-block"
    environment         = "test"
    block_public_access = true
    cost_center        = "engineering"
    project_name       = "test-project"
    owner             = "test-team"
    business_unit     = "engineering"
    application_name  = "test-app"
    data_classification = "internal"
  }

  assert {
    condition = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Public ACLs should be blocked"
  }

  assert {
    condition = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "Public policies should be blocked"
  }

  assert {
    condition = aws_s3_bucket_public_access_block.this.ignore_public_acls == true
    error_message = "Public ACLs should be ignored"
  }

  assert {
    condition = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "Public buckets should be restricted"
  }
}

# Test SSL-only policy configuration
run "test_ssl_only_policy" {
  command = plan

  variables {
    bucket_name         = "test-bucket-ssl-only"
    environment         = "test"
    enable_ssl_only     = true
    cost_center        = "engineering"
    project_name       = "test-project"
    owner             = "test-team"
    business_unit     = "engineering"
    application_name  = "test-app"
    data_classification = "internal"
  }

  assert {
    condition = length(aws_s3_bucket_policy.ssl_only) == 1
    error_message = "SSL-only policy should be created when enabled"
  }
}

# Test CCMS compliance tags
run "test_ccms_compliance_tags" {
  command = plan

  variables {
    bucket_name         = "test-bucket-ccms"
    environment         = "prod"
    cost_center        = "finance"
    project_name       = "critical-project"
    owner             = "finance-team"
    business_unit     = "finance"
    application_name  = "finance-app"
    data_classification = "confidential"
    
    additional_tags = {
      Department = "Finance"
      Criticality = "High"
    }
  }

  assert {
    condition = aws_s3_bucket.this.tags["CostCenter"] == "finance"
    error_message = "CostCenter tag should be set from variable"
  }

  assert {
    condition = aws_s3_bucket.this.tags["ProjectName"] == "critical-project"
    error_message = "ProjectName tag should be set from variable"
  }

  assert {
    condition = aws_s3_bucket.this.tags["Owner"] == "finance-team"
    error_message = "Owner tag should be set from variable"
  }

  assert {
    condition = aws_s3_bucket.this.tags["BusinessUnit"] == "finance"
    error_message = "BusinessUnit tag should be set from variable"
  }

  assert {
    condition = aws_s3_bucket.this.tags["ApplicationName"] == "finance-app"
    error_message = "ApplicationName tag should be set from variable"
  }

  assert {
    condition = aws_s3_bucket.this.tags["DataClassification"] == "confidential"
    error_message = "DataClassification tag should be set from variable"
  }

  assert {
    condition = aws_s3_bucket.this.tags["Department"] == "Finance"
    error_message = "Additional tags should be merged correctly"
  }
}

# Test environment-specific configurations
run "test_production_environment_defaults" {
  command = plan

  variables {
    bucket_name         = "test-bucket-prod"
    environment         = "prod"
    compliance_mode     = "strict"
    cost_center        = "engineering"
    project_name       = "prod-project"
    owner             = "prod-team"
    business_unit     = "engineering"
    application_name  = "prod-app"
    data_classification = "confidential"
  }

  assert {
    condition = aws_s3_bucket.this.tags["Environment"] == "prod"
    error_message = "Environment tag should reflect production"
  }

  assert {
    condition = aws_s3_bucket.this.tags["ComplianceMode"] == "strict"
    error_message = "ComplianceMode tag should be set for production"
  }
}

# Test variable validation
run "test_invalid_environment_rejected" {
  command = plan
  expect_failures = [var.environment]

  variables {
    bucket_name         = "test-bucket-invalid"
    environment         = "invalid-env"
    cost_center        = "engineering"
    project_name       = "test-project"
    owner             = "test-team"
    business_unit     = "engineering"
    application_name  = "test-app"
    data_classification = "internal"
  }
}

# Test invalid compliance mode rejected
run "test_invalid_compliance_mode_rejected" {
  command = plan
  expect_failures = [var.compliance_mode]

  variables {
    bucket_name         = "test-bucket-invalid-compliance"
    environment         = "test"
    compliance_mode     = "invalid-mode"
    cost_center        = "engineering"
    project_name       = "test-project"
    owner             = "test-team"
    business_unit     = "engineering"
    application_name  = "test-app"
    data_classification = "internal"
  }
}