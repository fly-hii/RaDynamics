# Terraform AWS IAM User Module - Main Configuration
# Comprehensive IAM User management with security compliance

# Local implementation of tags data
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-iam-user-module"
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

# Local values for configuration and tagging
locals {
  # Standard tags following CCMS requirements
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.resource_name
      Module      = "terraform-aws-iam-user"
      Environment = var.environment
      Component   = "iam-user"
      # Security Control IAM User Tagging Compliance
      SecurityControls     = "IAM-USER-01,IAM-USER-02,IAM-USER-03"
      MFARequired          = var.force_mfa ? "true" : "false"
      ConsoleAccess        = var.console_access ? "true" : "false"
      ProgrammaticAccess   = var.programmatic_access ? "true" : "false"
    },
    var.additional_tags
  )
}

# IAM User Resource
resource "aws_iam_user" "this" {
  name                 = var.username
  path                 = var.path
  permissions_boundary = var.permissions_boundary_arn
  force_destroy        = var.force_destroy
  
  tags = local.standard_tags
}

# IAM User Login Profile (Console Access)
resource "aws_iam_user_login_profile" "this" {
  count = var.console_access ? 1 : 0
  
  user                    = aws_iam_user.this.name
  password_reset_required = var.password_reset_required
  password_length         = var.password_length
  
  lifecycle {
    ignore_changes = [password_reset_required]
  }
}

# IAM Access Keys (Programmatic Access)
resource "aws_iam_access_key" "this" {
  count = var.programmatic_access ? var.access_key_count : 0
  
  user   = aws_iam_user.this.name
  status = "Active"
}

# IAM User Policy Attachments - AWS Managed Policies
resource "aws_iam_user_policy_attachment" "aws_managed" {
  count = length(var.aws_managed_policy_arns)
  
  user       = aws_iam_user.this.name
  policy_arn = var.aws_managed_policy_arns[count.index]
}

# IAM User Policy Attachments - Customer Managed Policies
resource "aws_iam_user_policy_attachment" "customer_managed" {
  count = length(var.customer_managed_policy_arns)
  
  user       = aws_iam_user.this.name
  policy_arn = var.customer_managed_policy_arns[count.index]
}

# Inline Policies
resource "aws_iam_user_policy" "inline_policies" {
  count = length(var.inline_policies)
  
  name   = var.inline_policies[count.index].name
  user   = aws_iam_user.this.name
  policy = var.inline_policies[count.index].policy
}

# IAM Group Memberships
resource "aws_iam_user_group_membership" "this" {
  count = length(var.group_memberships) > 0 ? 1 : 0
  
  user   = aws_iam_user.this.name
  groups = var.group_memberships
}

# MFA Device (Virtual MFA)
resource "aws_iam_virtual_mfa_device" "this" {
  count = var.create_mfa_device ? 1 : 0
  
  virtual_mfa_device_name = "${var.username}-mfa"
  path                    = var.path
  
  tags = merge(
    local.standard_tags,
    {
      Name      = "${var.username}-mfa"
      Component = "iam-mfa-device"
    }
  )
}

# SSH Public Key (for CodeCommit)
resource "aws_iam_user_ssh_key" "this" {
  count = var.ssh_public_key != null ? 1 : 0
  
  username   = aws_iam_user.this.name
  encoding   = "SSH"
  public_key = var.ssh_public_key
  status     = "Active"
}

# Service Specific Credentials (for services like CodeCommit)
resource "aws_iam_service_specific_credential" "this" {
  count = var.create_service_credentials ? 1 : 0
  
  user_name    = aws_iam_user.this.name
  service_name = var.service_name
  status       = "Active"
}

# CloudTrail for IAM User monitoring
resource "aws_cloudtrail" "iam_user_trail" {
  count = var.enable_cloudtrail_logging ? 1 : 0
  
  name           = "${var.username}-iam-trail"
  s3_bucket_name = var.cloudtrail_s3_bucket_name
  s3_key_prefix  = "iam-user-logs/"
  
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  
  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []
    
    data_resource {
      type   = "AWS::IAM::User"
      values = [aws_iam_user.this.arn]
    }
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name            = "${var.username}-iam-trail"
      SecurityControl = "IAM_USER_CloudTrail_Monitoring"
      LogType         = "iam_user_access"
    }
  )
}

# Password Policy Enforcement (Account Level)
resource "aws_iam_account_password_policy" "this" {
  count = var.enforce_password_policy ? 1 : 0
  
  minimum_password_length        = var.password_policy.minimum_length
  require_lowercase_characters   = var.password_policy.require_lowercase
  require_numbers               = var.password_policy.require_numbers
  require_uppercase_characters   = var.password_policy.require_uppercase
  require_symbols               = var.password_policy.require_symbols
  allow_users_to_change_password = var.password_policy.allow_users_to_change
  hard_expiry                   = var.password_policy.hard_expiry
  max_password_age              = var.password_policy.max_age_days
  password_reuse_prevention     = var.password_policy.reuse_prevention
}