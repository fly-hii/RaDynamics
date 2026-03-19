# Terraform AWS IAM Policy Module - Outputs
# Comprehensive outputs for IAM Policy module

#------------------------------------------------------------------------------
# IAM POLICY OUTPUTS
#------------------------------------------------------------------------------

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = aws_iam_policy.this.arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = aws_iam_policy.this.name
}

output "policy_id" {
  description = "ID of the IAM policy"
  value       = aws_iam_policy.this.id
}

output "policy_path" {
  description = "Path of the IAM policy"
  value       = aws_iam_policy.this.path
}

output "policy_description" {
  description = "Description of the IAM policy"
  value       = aws_iam_policy.this.description
}

output "policy_document" {
  description = "Policy document JSON"
  value       = aws_iam_policy.this.policy
}

#------------------------------------------------------------------------------
# POLICY VERSION OUTPUTS
#------------------------------------------------------------------------------

output "policy_version_id" {
  description = "Version ID of the policy"
  value       = var.create_policy_version ? aws_iam_policy_version.this[0].version_id : null
}

output "default_version_id" {
  description = "Default version ID of the policy"
  value       = aws_iam_policy.this.policy_id
}

#------------------------------------------------------------------------------
# ATTACHMENT OUTPUTS
#------------------------------------------------------------------------------

output "attached_users" {
  description = "Users the policy is attached to"
  value = [
    for attachment in aws_iam_user_policy_attachment.users : {
      user       = attachment.user
      policy_arn = attachment.policy_arn
    }
  ]
}

output "attached_roles" {
  description = "Roles the policy is attached to"
  value = [
    for attachment in aws_iam_role_policy_attachment.roles : {
      role       = attachment.role
      policy_arn = attachment.policy_arn
    }
  ]
}

output "attached_groups" {
  description = "Groups the policy is attached to"
  value = [
    for attachment in aws_iam_group_policy_attachment.groups : {
      group      = attachment.group
      policy_arn = attachment.policy_arn
    }
  ]
}

output "attachment_count" {
  description = "Total number of attachments"
  value = {
    users  = length(var.attach_to_users)
    roles  = length(var.attach_to_roles)
    groups = length(var.attach_to_groups)
    total  = length(var.attach_to_users) + length(var.attach_to_roles) + length(var.attach_to_groups)
  }
}

#------------------------------------------------------------------------------
# POLICY ANALYSIS OUTPUTS
#------------------------------------------------------------------------------

output "policy_analysis" {
  description = "Analysis of the policy document"
  value = {
    version           = jsondecode(var.policy_document).Version
    statement_count   = length(jsondecode(var.policy_document).Statement)
    policy_size       = length(var.policy_document)
    max_size          = 6144
    size_percentage   = round((length(var.policy_document) / 6144) * 100, 2)
    valid_json        = can(jsondecode(var.policy_document))
    policy_type       = var.policy_type
  }
}

output "policy_statements" {
  description = "Individual policy statements analysis"
  value = [
    for idx, statement in jsondecode(var.policy_document).Statement : {
      index     = idx
      effect    = statement.Effect
      actions   = try(statement.Action, [])
      resources = try(statement.Resource, [])
      conditions = try(statement.Condition, {})
      principals = try(statement.Principal, {})
    }
  ]
}

output "policy_permissions" {
  description = "Summary of permissions granted by the policy"
  value = {
    allows_all_actions    = anytrue([for stmt in jsondecode(var.policy_document).Statement : stmt.Effect == "Allow" && contains(try(stmt.Action, []), "*")])
    allows_all_resources  = anytrue([for stmt in jsondecode(var.policy_document).Statement : stmt.Effect == "Allow" && contains(try(stmt.Resource, []), "*")])
    has_deny_statements   = anytrue([for stmt in jsondecode(var.policy_document).Statement : stmt.Effect == "Deny"])
    has_conditions        = anytrue([for stmt in jsondecode(var.policy_document).Statement : length(try(stmt.Condition, {})) > 0])
    total_statements      = length(jsondecode(var.policy_document).Statement)
    allow_statements      = length([for stmt in jsondecode(var.policy_document).Statement : stmt if stmt.Effect == "Allow"])
    deny_statements       = length([for stmt in jsondecode(var.policy_document).Statement : stmt if stmt.Effect == "Deny"])
  }
}

#------------------------------------------------------------------------------
# CLOUDTRAIL OUTPUTS
#------------------------------------------------------------------------------

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail_logging ? aws_cloudtrail.iam_policy_trail[0].arn : null
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = var.enable_cloudtrail_logging ? aws_cloudtrail.iam_policy_trail[0].name : null
}

#------------------------------------------------------------------------------
# SECURITY OUTPUTS
#------------------------------------------------------------------------------

output "security_analysis" {
  description = "Security analysis of the policy"
  value = {
    overly_permissive = anytrue([
      for stmt in jsondecode(var.policy_document).Statement : 
      stmt.Effect == "Allow" && contains(try(stmt.Action, []), "*") && contains(try(stmt.Resource, []), "*")
    ])
    
    has_resource_restrictions = anytrue([
      for stmt in jsondecode(var.policy_document).Statement : 
      stmt.Effect == "Allow" && length(try(stmt.Resource, [])) > 0 && !contains(try(stmt.Resource, []), "*")
    ])
    
    has_condition_restrictions = anytrue([
      for stmt in jsondecode(var.policy_document).Statement : 
      length(try(stmt.Condition, {})) > 0
    ])
    
    uses_least_privilege = alltrue([
      for stmt in jsondecode(var.policy_document).Statement : 
      stmt.Effect == "Allow" ? (!contains(try(stmt.Action, []), "*") || !contains(try(stmt.Resource, []), "*")) : true
    ])
    
    risk_level = anytrue([
      for stmt in jsondecode(var.policy_document).Statement : 
      stmt.Effect == "Allow" && contains(try(stmt.Action, []), "*") && contains(try(stmt.Resource, []), "*")
    ]) ? "HIGH" : anytrue([
      for stmt in jsondecode(var.policy_document).Statement : 
      stmt.Effect == "Allow" && (contains(try(stmt.Action, []), "*") || contains(try(stmt.Resource, []), "*"))
    ]) ? "MEDIUM" : "LOW"
  }
}

#------------------------------------------------------------------------------
# TAGGING OUTPUTS
#------------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the IAM policy"
  value       = aws_iam_policy.this.tags_all
}

output "policy_tags" {
  description = "Tags applied specifically to the IAM policy resource"
  value       = aws_iam_policy.this.tags
}

#------------------------------------------------------------------------------
# COMPUTED OUTPUTS
#------------------------------------------------------------------------------

output "policy_summary" {
  description = "Summary of IAM policy configuration"
  value = {
    arn         = aws_iam_policy.this.arn
    name        = aws_iam_policy.this.name
    path        = aws_iam_policy.this.path
    description = aws_iam_policy.this.description
    type        = var.policy_type
    attachments = length(var.attach_to_users) + length(var.attach_to_roles) + length(var.attach_to_groups)
    environment = var.environment
  }
}

#------------------------------------------------------------------------------
# USAGE INSTRUCTIONS
#------------------------------------------------------------------------------

output "usage_instructions" {
  description = "Instructions for using the IAM policy"
  value = {
    attach_to_user_command = "aws iam attach-user-policy --user-name <username> --policy-arn ${aws_iam_policy.this.arn}"
    attach_to_role_command = "aws iam attach-role-policy --role-name <rolename> --policy-arn ${aws_iam_policy.this.arn}"
    attach_to_group_command = "aws iam attach-group-policy --group-name <groupname> --policy-arn ${aws_iam_policy.this.arn}"
    
    simulate_policy_command = "aws iam simulate-principal-policy --policy-source-arn ${aws_iam_policy.this.arn} --action-names <action> --resource-arns <resource>"
    
    policy_versions_command = "aws iam list-policy-versions --policy-arn ${aws_iam_policy.this.arn}"
    
    get_policy_command = "aws iam get-policy --policy-arn ${aws_iam_policy.this.arn}"
  }
}

#------------------------------------------------------------------------------
# VALIDATION OUTPUTS
#------------------------------------------------------------------------------

output "validation_results" {
  description = "Policy validation results"
  value = {
    valid_json_structure = can(jsondecode(var.policy_document))
    has_required_fields = can(jsondecode(var.policy_document).Version) && can(jsondecode(var.policy_document).Statement)
    within_size_limit = length(var.policy_document) <= 6144
    policy_complexity = length(jsondecode(var.policy_document).Statement)
    
    validation_status = can(jsondecode(var.policy_document)) && 
                       can(jsondecode(var.policy_document).Version) && 
                       can(jsondecode(var.policy_document).Statement) && 
                       length(var.policy_document) <= 6144 ? "VALID" : "INVALID"
  }
}