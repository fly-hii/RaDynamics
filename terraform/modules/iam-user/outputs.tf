# Terraform AWS IAM User Module - Outputs
# Comprehensive outputs for IAM User module

#------------------------------------------------------------------------------
# IAM USER OUTPUTS
#------------------------------------------------------------------------------

output "user_arn" {
  description = "ARN of the IAM user"
  value       = aws_iam_user.this.arn
}

output "user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user.this.name
}

output "user_unique_id" {
  description = "Unique ID of the IAM user"
  value       = aws_iam_user.this.unique_id
}

output "user_path" {
  description = "Path of the IAM user"
  value       = aws_iam_user.this.path
}

#------------------------------------------------------------------------------
# ACCESS CREDENTIALS OUTPUTS
#------------------------------------------------------------------------------

output "console_login_url" {
  description = "AWS Console login URL"
  value       = var.console_access ? "https://console.aws.amazon.com/" : null
}

output "password" {
  description = "Initial password for console access (sensitive)"
  value       = var.console_access ? aws_iam_user_login_profile.this[0].password : null
  sensitive   = true
}

output "access_keys" {
  description = "Access keys for programmatic access (sensitive)"
  value = var.programmatic_access ? [
    for key in aws_iam_access_key.this : {
      id     = key.id
      secret = key.secret
      status = key.status
    }
  ] : []
  sensitive = true
}

output "access_key_ids" {
  description = "Access key IDs (non-sensitive)"
  value = var.programmatic_access ? [
    for key in aws_iam_access_key.this : key.id
  ] : []
}

#------------------------------------------------------------------------------
# POLICY ATTACHMENT OUTPUTS
#------------------------------------------------------------------------------

output "aws_managed_policy_attachments" {
  description = "AWS managed policies attached to the user"
  value = [
    for attachment in aws_iam_user_policy_attachment.aws_managed : {
      policy_arn = attachment.policy_arn
      user       = attachment.user
    }
  ]
}

output "customer_managed_policy_attachments" {
  description = "Customer managed policies attached to the user"
  value = [
    for attachment in aws_iam_user_policy_attachment.customer_managed : {
      policy_arn = attachment.policy_arn
      user       = attachment.user
    }
  ]
}

output "inline_policies" {
  description = "Inline policies attached to the user"
  value = [
    for policy in aws_iam_user_policy.inline_policies : {
      name   = policy.name
      policy = policy.policy
      user   = policy.user
    }
  ]
}

output "attached_policy_count" {
  description = "Total number of policies attached to the user"
  value = {
    aws_managed      = length(var.aws_managed_policy_arns)
    customer_managed = length(var.customer_managed_policy_arns)
    inline          = length(var.inline_policies)
    total           = length(var.aws_managed_policy_arns) + length(var.customer_managed_policy_arns) + length(var.inline_policies)
  }
}

#------------------------------------------------------------------------------
# GROUP MEMBERSHIP OUTPUTS
#------------------------------------------------------------------------------

output "group_memberships" {
  description = "Groups the user is a member of"
  value       = var.group_memberships
}

#------------------------------------------------------------------------------
# MFA OUTPUTS
#------------------------------------------------------------------------------

output "mfa_device_arn" {
  description = "ARN of the virtual MFA device"
  value       = var.create_mfa_device ? aws_iam_virtual_mfa_device.this[0].arn : null
}

output "mfa_device_base32_string_seed" {
  description = "Base32 string seed for MFA device (sensitive)"
  value       = var.create_mfa_device ? aws_iam_virtual_mfa_device.this[0].base_32_string_seed : null
  sensitive   = true
}

output "mfa_device_qr_code_png" {
  description = "QR code PNG for MFA device setup (sensitive)"
  value       = var.create_mfa_device ? aws_iam_virtual_mfa_device.this[0].qr_code_png : null
  sensitive   = true
}

#------------------------------------------------------------------------------
# SSH AND SERVICE CREDENTIALS OUTPUTS
#------------------------------------------------------------------------------

output "ssh_key_id" {
  description = "SSH key ID for CodeCommit"
  value       = var.ssh_public_key != null ? aws_iam_user_ssh_key.this[0].ssh_public_key_id : null
}

output "service_credentials" {
  description = "Service-specific credentials (sensitive)"
  value = var.create_service_credentials ? {
    username = aws_iam_service_specific_credential.this[0].service_user_name
    password = aws_iam_service_specific_credential.this[0].service_password
    status   = aws_iam_service_specific_credential.this[0].status
  } : null
  sensitive = true
}

#------------------------------------------------------------------------------
# CLOUDTRAIL OUTPUTS
#------------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail_logging ? aws_cloudtrail.iam_user_trail[0].arn : null
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = var.enable_cloudtrail_logging ? aws_cloudtrail.iam_user_trail[0].name : null
}

#------------------------------------------------------------------------------
# SECURITY OUTPUTS
#------------------------------------------------------------------------------

output "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy"
  value       = aws_iam_user.this.permissions_boundary
}

output "security_summary" {
  description = "Security configuration summary"
  value = {
    console_access        = var.console_access
    programmatic_access   = var.programmatic_access
    mfa_device_created    = var.create_mfa_device
    permissions_boundary  = var.permissions_boundary_arn != null
    cloudtrail_enabled    = var.enable_cloudtrail_logging
    force_mfa            = var.force_mfa
    ssh_key_configured   = var.ssh_public_key != null
  }
}

#------------------------------------------------------------------------------
# TAGGING OUTPUTS
#------------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the IAM user"
  value       = aws_iam_user.this.tags_all
}

output "user_tags" {
  description = "Tags applied specifically to the IAM user resource"
  value       = aws_iam_user.this.tags
}

#------------------------------------------------------------------------------
# COMPUTED OUTPUTS
#------------------------------------------------------------------------------

output "user_summary" {
  description = "Summary of IAM user configuration"
  value = {
    arn                  = aws_iam_user.this.arn
    name                 = aws_iam_user.this.name
    path                 = aws_iam_user.this.path
    permissions_boundary = aws_iam_user.this.permissions_boundary
    console_access       = var.console_access
    programmatic_access  = var.programmatic_access
    mfa_enabled         = var.create_mfa_device
    environment         = var.environment
  }
}

output "access_summary" {
  description = "Summary of user access configuration"
  value = {
    console_login_available    = var.console_access
    access_keys_count         = var.programmatic_access ? var.access_key_count : 0
    group_memberships_count   = length(var.group_memberships)
    attached_policies_count   = length(var.aws_managed_policy_arns) + length(var.customer_managed_policy_arns) + length(var.inline_policies)
    mfa_device_configured     = var.create_mfa_device
    ssh_access_configured     = var.ssh_public_key != null
    service_credentials_created = var.create_service_credentials
  }
}

#------------------------------------------------------------------------------
# USAGE INSTRUCTIONS
#------------------------------------------------------------------------------

output "usage_instructions" {
  description = "Instructions for using the IAM user"
  value = {
    console_login = var.console_access ? {
      url      = "https://console.aws.amazon.com/"
      username = aws_iam_user.this.name
      note     = "Use the generated password (check sensitive outputs)"
    } : null
    
    programmatic_access = var.programmatic_access ? {
      aws_configure_command = "aws configure --profile ${aws_iam_user.this.name}"
      note                 = "Use the generated access key and secret (check sensitive outputs)"
    } : null
    
    mfa_setup = var.create_mfa_device ? {
      step1 = "Scan the QR code with your MFA app"
      step2 = "Enter two consecutive MFA codes to activate"
      step3 = "MFA will be required for console login"
    } : null
  }
}