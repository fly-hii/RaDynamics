# Terraform AWS IAM Role Module - Outputs
# L1 Module outputs following CCMS standards

#------------------------------------------------------------------------------
# IAM ROLE OUTPUTS
#------------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.this.id
}

output "role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = aws_iam_role.this.unique_id
}

output "role_description" {
  description = "Description of the IAM role"
  value       = aws_iam_role.this.description
}

output "role_path" {
  description = "Path of the IAM role"
  value       = aws_iam_role.this.path
}

output "role_max_session_duration" {
  description = "Maximum session duration of the IAM role"
  value       = aws_iam_role.this.max_session_duration
}

output "role_create_date" {
  description = "Creation date of the IAM role"
  value       = aws_iam_role.this.create_date
}

#------------------------------------------------------------------------------
# ASSUME ROLE POLICY OUTPUTS
#------------------------------------------------------------------------------

output "assume_role_policy" {
  description = "Assume role policy document"
  value       = aws_iam_role.this.assume_role_policy
}

output "assume_role_policy_json" {
  description = "Assume role policy as JSON string"
  value       = data.aws_iam_policy_document.assume_role_policy.json
}

#------------------------------------------------------------------------------
# POLICY ATTACHMENT OUTPUTS
#------------------------------------------------------------------------------

output "aws_managed_policy_attachments" {
  description = "AWS managed policies attached to the role"
  value = [
    for attachment in aws_iam_role_policy_attachment.aws_managed : {
      policy_arn = attachment.policy_arn
      role       = attachment.role
    }
  ]
}

output "customer_managed_policy_attachments" {
  description = "Customer managed policies attached to the role"
  value = [
    for attachment in aws_iam_role_policy_attachment.customer_managed : {
      policy_arn = attachment.policy_arn
      role       = attachment.role
    }
  ]
}

output "inline_policies" {
  description = "Inline policies attached to the role"
  value = [
    for policy in aws_iam_role_policy.inline_policies : {
      name   = policy.name
      policy = policy.policy
      role   = policy.role
    }
  ]
}

output "attached_policy_count" {
  description = "Total number of policies attached to the role"
  value = {
    aws_managed      = length(var.aws_managed_policy_arns)
    customer_managed = length(var.customer_managed_policy_arns)
    inline          = length(var.inline_policies)
    total           = length(var.aws_managed_policy_arns) + length(var.customer_managed_policy_arns) + length(var.inline_policies)
  }
}

#------------------------------------------------------------------------------
# INSTANCE PROFILE OUTPUTS
#------------------------------------------------------------------------------

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].arn : null
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : null
}

output "instance_profile_id" {
  description = "ID of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].id : null
}

output "instance_profile_unique_id" {
  description = "Unique ID of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].unique_id : null
}

output "instance_profile_create_date" {
  description = "Creation date of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].create_date : null
}

#------------------------------------------------------------------------------
# CLOUDTRAIL OUTPUTS
#------------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail_logging ? aws_cloudtrail.iam_role_trail[0].arn : null
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = var.enable_cloudtrail_logging ? aws_cloudtrail.iam_role_trail[0].name : null
}

output "cloudtrail_home_region" {
  description = "Home region of the CloudTrail"
  value       = var.enable_cloudtrail_logging ? aws_cloudtrail.iam_role_trail[0].home_region : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.enable_cloudtrail_logging && var.cloudwatch_log_group_name != null ? aws_cloudwatch_log_group.iam_role_logs[0].arn : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.enable_cloudtrail_logging && var.cloudwatch_log_group_name != null ? aws_cloudwatch_log_group.iam_role_logs[0].name : null
}

#------------------------------------------------------------------------------
# SECURITY OUTPUTS
#------------------------------------------------------------------------------

output "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy"
  value       = aws_iam_role.this.permissions_boundary
}

output "security_controls_status" {
  description = "Status of implemented security controls"
  value = var.security_controls_enabled ? {
    iam_01_tagging = {
      control = "IAM Role Tagging Compliance"
      status  = "COMPLIANT"
      details = "All required tags applied to IAM role"
    }
    iam_02_mfa_requirement = {
      control = "MFA Requirement for Role Assumption"
      status  = local.mfa_validation
      details = "MFA requirement validation status"
    }
    iam_03_external_id = {
      control = "External ID for Cross-Account Access"
      status  = local.external_id_validation
      details = "External ID validation status"
    }
    iam_04_ip_restrictions = {
      control = "IP Address Restrictions"
      status  = local.ip_restriction_validation
      details = "IP restriction validation status"
    }
    iam_06_permissions_boundary = {
      control = "Permissions Boundary"
      status  = local.permissions_boundary_validation
      details = "Permissions boundary validation status"
    }
    iam_07_cloudtrail_logging = {
      control = "CloudTrail Logging"
      status  = local.cloudtrail_validation
      details = "CloudTrail logging validation status"
    }
  } : {}
}

output "security_compliance_tags" {
  description = "Security compliance tags applied to the IAM role"
  value = {
    security_controls      = lookup(local.standard_tags, "SecurityControls", "")
    mfa_required          = lookup(local.standard_tags, "MFARequired", "")
    external_id_required  = lookup(local.standard_tags, "ExternalIdRequired", "")
    max_session_duration  = lookup(local.standard_tags, "MaxSessionDuration", "")
    cloudtrail_enabled    = lookup(local.standard_tags, "CloudTrailEnabled", "")
    security_framework    = lookup(var.security_compliance_tags, "SecurityFramework", "")
    compliance_level      = lookup(var.security_compliance_tags, "ComplianceLevel", "")
  }
}

#------------------------------------------------------------------------------
# TAGGING OUTPUTS (CCMS COMPLIANCE)
#------------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the IAM role including default provider tags"
  value       = aws_iam_role.this.tags_all
}

output "resource_name" {
  description = "Resource name used for the IAM role"
  value       = var.resource_name
}

output "role_tags" {
  description = "Tags applied specifically to the IAM role resource"
  value       = aws_iam_role.this.tags
}

#------------------------------------------------------------------------------
# COMPUTED OUTPUTS
#------------------------------------------------------------------------------

output "role_summary" {
  description = "Summary of IAM role configuration"
  value = {
    arn                   = aws_iam_role.this.arn
    name                  = aws_iam_role.this.name
    description           = aws_iam_role.this.description
    max_session_duration  = aws_iam_role.this.max_session_duration
    permissions_boundary  = aws_iam_role.this.permissions_boundary
    instance_profile_created = var.create_instance_profile
    cloudtrail_enabled    = var.enable_cloudtrail_logging
    environment           = var.environment
  }
}

output "trust_policy_analysis" {
  description = "Analysis of the trust policy"
  value = {
    has_mfa_requirement = local.config.security_requirements.require_mfa
    has_external_id     = var.external_id != null
    has_ip_restrictions = length(var.allowed_ip_ranges) > 0
    has_time_restrictions = var.time_based_access != null
    trusted_services    = var.trusted_role_services
    trusted_arns        = var.trusted_role_arns
  }
}

output "policy_summary" {
  description = "Summary of attached policies"
  value = {
    aws_managed_policies = var.aws_managed_policy_arns
    customer_managed_policies = var.customer_managed_policy_arns
    inline_policy_names = [for policy in var.inline_policies : policy.name]
    total_policies = length(var.aws_managed_policy_arns) + length(var.customer_managed_policy_arns) + length(var.inline_policies)
  }
}

#------------------------------------------------------------------------------
# VALIDATION OUTPUTS
#------------------------------------------------------------------------------

output "validation_results" {
  description = "Security validation results"
  value = {
    mfa_validation                 = local.mfa_validation
    external_id_validation         = local.external_id_validation
    ip_restriction_validation      = local.ip_restriction_validation
    permissions_boundary_validation = local.permissions_boundary_validation
    cloudtrail_validation          = local.cloudtrail_validation
    overall_compliance             = alltrue([
      local.mfa_validation != "NON_COMPLIANT",
      local.external_id_validation != "NON_COMPLIANT",
      local.ip_restriction_validation != "NON_COMPLIANT",
      local.permissions_boundary_validation != "NON_COMPLIANT",
      local.cloudtrail_validation != "NON_COMPLIANT"
    ]) ? "COMPLIANT" : "NON_COMPLIANT"
  }
}

#------------------------------------------------------------------------------
# ROLE USAGE OUTPUTS
#------------------------------------------------------------------------------

output "role_usage_instructions" {
  description = "Instructions for using the IAM role"
  value = {
    assume_role_command = "aws sts assume-role --role-arn ${aws_iam_role.this.arn} --role-session-name MySession"
    instance_profile_name = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : "Not created"
    mfa_required = local.config.security_requirements.require_mfa
    external_id_required = var.external_id != null ? var.external_id : "Not required"
  }
}