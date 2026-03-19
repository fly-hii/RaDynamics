# Terraform AWS IAM Role Module - Main Configuration
# L1 Module for IAM Role provisioning with security compliance

# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-iam-role-module"
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
      require_mfa           = var.environment == "prod" ? true : var.require_mfa
      max_session_duration  = var.environment == "prod" ? 3600 : var.max_session_duration
      require_external_id   = var.environment == "prod" ? true : var.require_external_id
      enable_cloudtrail     = var.environment == "prod" ? true : var.enable_cloudtrail_logging
    }
  }
}

# Data sources for policy documents
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    
    principals {
      type        = var.trusted_role_services != null ? "Service" : "AWS"
      identifiers = var.trusted_role_services != null ? var.trusted_role_services : var.trusted_role_arns
    }
    
    actions = ["sts:AssumeRole"]
    
    # Conditional MFA requirement (Security Control IAM-02)
    dynamic "condition" {
      for_each = local.config.security_requirements.require_mfa ? [1] : []
      
      content {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }
    
    # Conditional External ID requirement (Security Control IAM-03)
    dynamic "condition" {
      for_each = var.external_id != null ? [1] : []
      
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.external_id]
      }
    }
    
    # IP restriction condition (Security Control IAM-04)
    dynamic "condition" {
      for_each = length(var.allowed_ip_ranges) > 0 ? [1] : []
      
      content {
        test     = "IpAddress"
        variable = "aws:SourceIp"
        values   = var.allowed_ip_ranges
      }
    }
    
    # Time-based access condition (Security Control IAM-05)
    dynamic "condition" {
      for_each = var.time_based_access != null ? [1] : []
      
      content {
        test     = "DateGreaterThan"
        variable = "aws:CurrentTime"
        values   = [var.time_based_access.start_time]
      }
    }
    
    dynamic "condition" {
      for_each = var.time_based_access != null ? [1] : []
      
      content {
        test     = "DateLessThan"
        variable = "aws:CurrentTime"
        values   = [var.time_based_access.end_time]
      }
    }
  }
}

# Local values for configuration and tagging
locals {
  # Standard tags following CCMS requirements with Security Controls
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.resource_name
      Module      = "terraform-aws-l1-iam-role"
      Environment = var.environment
      Component   = "iam-role"
      # Security Control IAM-01: IAM Role Tagging Compliance
      SecurityControls     = "IAM-01,IAM-02,IAM-03,IAM-04,IAM-05,IAM-06"
      MFARequired          = local.config.security_requirements.require_mfa ? "true" : "false"
      ExternalIdRequired   = var.external_id != null ? "true" : "false"
      MaxSessionDuration   = tostring(local.config.security_requirements.max_session_duration)
      CloudTrailEnabled    = local.config.security_requirements.enable_cloudtrail ? "true" : "false"
    },
    var.security_compliance_tags,
    var.additional_tags
  )
}

# IAM Role Resource
resource "aws_iam_role" "this" {
  name                 = var.role_name_prefix != null ? null : var.resource_name
  name_prefix          = var.role_name_prefix
  description          = var.description
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  path                 = var.path
  max_session_duration = local.config.security_requirements.max_session_duration
  
  # Permissions boundary (Security Control IAM-06)
  permissions_boundary = var.permissions_boundary_arn
  
  # Force detach policies on destroy
  force_detach_policies = var.force_detach_policies
  
  tags = local.standard_tags
}

# IAM Role Policy Attachments - AWS Managed Policies
resource "aws_iam_role_policy_attachment" "aws_managed" {
  count = length(var.aws_managed_policy_arns)
  
  role       = aws_iam_role.this.name
  policy_arn = var.aws_managed_policy_arns[count.index]
}

# IAM Role Policy Attachments - Customer Managed Policies
resource "aws_iam_role_policy_attachment" "customer_managed" {
  count = length(var.customer_managed_policy_arns)
  
  role       = aws_iam_role.this.name
  policy_arn = var.customer_managed_policy_arns[count.index]
}

# Inline Policies
resource "aws_iam_role_policy" "inline_policies" {
  count = length(var.inline_policies)
  
  name   = var.inline_policies[count.index].name
  role   = aws_iam_role.this.id
  policy = var.inline_policies[count.index].policy
}

# Instance Profile (for EC2 instances)
resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0
  
  name        = var.instance_profile_name != null ? var.instance_profile_name : var.resource_name
  name_prefix = var.instance_profile_name_prefix
  path        = var.path
  role        = aws_iam_role.this.name
  
  tags = merge(
    local.standard_tags,
    {
      Name      = var.instance_profile_name != null ? var.instance_profile_name : var.resource_name
      Component = "iam-instance-profile"
    }
  )
}

# CloudTrail for IAM Role monitoring (Security Control IAM-07)
resource "aws_cloudtrail" "iam_role_trail" {
  count = var.enable_cloudtrail_logging ? 1 : 0
  
  name           = "${var.resource_name}-iam-trail"
  s3_bucket_name = var.cloudtrail_s3_bucket_name
  s3_key_prefix  = "iam-role-logs/"
  
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  
  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []
    
    data_resource {
      type   = "AWS::IAM::Role"
      values = [aws_iam_role.this.arn]
    }
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name            = "${var.resource_name}-iam-trail"
      SecurityControl = "IAM_07_CloudTrail_Monitoring"
      LogType         = "iam_role_access"
    }
  )
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "iam_role_logs" {
  count = var.enable_cloudtrail_logging && var.cloudwatch_log_group_name != null ? 1 : 0
  
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.cloudwatch_kms_key_id
  
  tags = merge(
    local.standard_tags,
    {
      Name            = var.cloudwatch_log_group_name
      SecurityControl = "IAM_07_CloudWatch_Logging"
      LogType         = "iam_role_cloudwatch"
    }
  )
}

# Security Control Validation - Local values for validation
locals {
  # Security Control IAM-02: Validate MFA requirement
  mfa_validation = local.config.security_requirements.require_mfa ? (
    can(regex("aws:MultiFactorAuthPresent", data.aws_iam_policy_document.assume_role_policy.json)) ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"
  
  # Security Control IAM-03: Validate External ID
  external_id_validation = var.external_id != null ? (
    can(regex("sts:ExternalId", data.aws_iam_policy_document.assume_role_policy.json)) ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "NOT_REQUIRED"
  
  # Security Control IAM-04: Validate IP restrictions
  ip_restriction_validation = length(var.allowed_ip_ranges) > 0 ? (
    can(regex("aws:SourceIp", data.aws_iam_policy_document.assume_role_policy.json)) ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "NOT_CONFIGURED"
  
  # Security Control IAM-06: Validate permissions boundary
  permissions_boundary_validation = var.permissions_boundary_arn != null ? "COMPLIANT" : "NOT_CONFIGURED"
  
  # Security Control IAM-07: Validate CloudTrail logging
  cloudtrail_validation = var.enable_cloudtrail_logging ? (
    var.cloudtrail_s3_bucket_name != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"
}

# Security Control Validation Output
resource "null_resource" "security_controls_validation" {
  count = var.security_controls_enabled ? 1 : 0
  
  triggers = {
    mfa_status                 = local.mfa_validation
    external_id_status         = local.external_id_validation
    ip_restriction_status      = local.ip_restriction_validation
    permissions_boundary_status = local.permissions_boundary_validation
    cloudtrail_status          = local.cloudtrail_validation
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "IAM Role Security Controls Validation Report:"
      echo "IAM-02 MFA Requirement: ${local.mfa_validation}"
      echo "IAM-03 External ID: ${local.external_id_validation}"
      echo "IAM-04 IP Restrictions: ${local.ip_restriction_validation}"
      echo "IAM-06 Permissions Boundary: ${local.permissions_boundary_validation}"
      echo "IAM-07 CloudTrail Logging: ${local.cloudtrail_validation}"
    EOT
  }
}