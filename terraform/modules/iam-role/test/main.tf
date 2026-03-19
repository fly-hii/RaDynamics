
# Test configuration for iam-role module
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider (using environment variables)
provider "aws" {
  region = var.aws_region
  
  # Skip credentials validation for testing
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
}

# Use the module
module "iam_role_test" {
  source = "../"
  
  role_name = "test-iam-role-deployment"
  assume_role_policy = "{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}"
  description = "Test IAM role for deployment validation"
  max_session_duration = 3600
  path = "/"
  policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  tags = {"Environment":"test","Purpose":"deployment-validation"}
}

# Output the module outputs
output "test_role_arn" {
  description = "Test output for role_arn"
  value       = module.iam_role_test.role_arn
}

output "test_role_name" {
  description = "Test output for role_name"
  value       = module.iam_role_test.role_name
}

output "test_role_id" {
  description = "Test output for role_id"
  value       = module.iam_role_test.role_id
}

output "test_role_unique_id" {
  description = "Test output for role_unique_id"
  value       = module.iam_role_test.role_unique_id
}

output "test_role_description" {
  description = "Test output for role_description"
  value       = module.iam_role_test.role_description
}

output "test_role_path" {
  description = "Test output for role_path"
  value       = module.iam_role_test.role_path
}

output "test_role_max_session_duration" {
  description = "Test output for role_max_session_duration"
  value       = module.iam_role_test.role_max_session_duration
}

output "test_role_create_date" {
  description = "Test output for role_create_date"
  value       = module.iam_role_test.role_create_date
}

output "test_assume_role_policy" {
  description = "Test output for assume_role_policy"
  value       = module.iam_role_test.assume_role_policy
}

output "test_assume_role_policy_json" {
  description = "Test output for assume_role_policy_json"
  value       = module.iam_role_test.assume_role_policy_json
}

output "test_aws_managed_policy_attachments" {
  description = "Test output for aws_managed_policy_attachments"
  value       = module.iam_role_test.aws_managed_policy_attachments
}

output "test_customer_managed_policy_attachments" {
  description = "Test output for customer_managed_policy_attachments"
  value       = module.iam_role_test.customer_managed_policy_attachments
}

output "test_inline_policies" {
  description = "Test output for inline_policies"
  value       = module.iam_role_test.inline_policies
}

output "test_attached_policy_count" {
  description = "Test output for attached_policy_count"
  value       = module.iam_role_test.attached_policy_count
}

output "test_instance_profile_arn" {
  description = "Test output for instance_profile_arn"
  value       = module.iam_role_test.instance_profile_arn
}

output "test_instance_profile_name" {
  description = "Test output for instance_profile_name"
  value       = module.iam_role_test.instance_profile_name
}

output "test_instance_profile_id" {
  description = "Test output for instance_profile_id"
  value       = module.iam_role_test.instance_profile_id
}

output "test_instance_profile_unique_id" {
  description = "Test output for instance_profile_unique_id"
  value       = module.iam_role_test.instance_profile_unique_id
}

output "test_instance_profile_create_date" {
  description = "Test output for instance_profile_create_date"
  value       = module.iam_role_test.instance_profile_create_date
}

output "test_cloudtrail_arn" {
  description = "Test output for cloudtrail_arn"
  value       = module.iam_role_test.cloudtrail_arn
}

output "test_cloudtrail_name" {
  description = "Test output for cloudtrail_name"
  value       = module.iam_role_test.cloudtrail_name
}

output "test_cloudtrail_home_region" {
  description = "Test output for cloudtrail_home_region"
  value       = module.iam_role_test.cloudtrail_home_region
}

output "test_cloudwatch_log_group_arn" {
  description = "Test output for cloudwatch_log_group_arn"
  value       = module.iam_role_test.cloudwatch_log_group_arn
}

output "test_cloudwatch_log_group_name" {
  description = "Test output for cloudwatch_log_group_name"
  value       = module.iam_role_test.cloudwatch_log_group_name
}

output "test_permissions_boundary_arn" {
  description = "Test output for permissions_boundary_arn"
  value       = module.iam_role_test.permissions_boundary_arn
}

output "test_security_controls_status" {
  description = "Test output for security_controls_status"
  value       = module.iam_role_test.security_controls_status
}

output "test_security_compliance_tags" {
  description = "Test output for security_compliance_tags"
  value       = module.iam_role_test.security_compliance_tags
}

output "test_tags_all" {
  description = "Test output for tags_all"
  value       = module.iam_role_test.tags_all
}

output "test_resource_name" {
  description = "Test output for resource_name"
  value       = module.iam_role_test.resource_name
}

output "test_role_tags" {
  description = "Test output for role_tags"
  value       = module.iam_role_test.role_tags
}

output "test_role_summary" {
  description = "Test output for role_summary"
  value       = module.iam_role_test.role_summary
}

output "test_trust_policy_analysis" {
  description = "Test output for trust_policy_analysis"
  value       = module.iam_role_test.trust_policy_analysis
}

output "test_policy_summary" {
  description = "Test output for policy_summary"
  value       = module.iam_role_test.policy_summary
}

output "test_validation_results" {
  description = "Test output for validation_results"
  value       = module.iam_role_test.validation_results
}

output "test_role_usage_instructions" {
  description = "Test output for role_usage_instructions"
  value       = module.iam_role_test.role_usage_instructions
}
