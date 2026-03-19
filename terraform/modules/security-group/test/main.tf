
# Test configuration for security-group module
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
module "security_group_test" {
  source = "../"
  
  group_name = "test-security-group-deployment"
  description = "Test security group for deployment validation"
  vpc_id = "vpc-12345678"
  ingress_rules = [{"from_port":80,"to_port":80,"protocol":"tcp","cidr_blocks":["0.0.0.0/0"],"description":"HTTP access"},{"from_port":443,"to_port":443,"protocol":"tcp","cidr_blocks":["0.0.0.0/0"],"description":"HTTPS access"}]
  egress_rules = [{"from_port":0,"to_port":0,"protocol":"-1","cidr_blocks":["0.0.0.0/0"],"description":"All outbound traffic"}]
  tags = {"Environment":"test","Purpose":"deployment-validation"}
}

# Output the module outputs
output "test_security_group_id" {
  description = "Test output for security_group_id"
  value       = module.security_group_test.security_group_id
}

output "test_security_group_arn" {
  description = "Test output for security_group_arn"
  value       = module.security_group_test.security_group_arn
}

output "test_security_group_name" {
  description = "Test output for security_group_name"
  value       = module.security_group_test.security_group_name
}

output "test_security_group_description" {
  description = "Test output for security_group_description"
  value       = module.security_group_test.security_group_description
}

output "test_vpc_id" {
  description = "Test output for vpc_id"
  value       = module.security_group_test.vpc_id
}

output "test_owner_id" {
  description = "Test output for owner_id"
  value       = module.security_group_test.owner_id
}

output "test_ingress_rules" {
  description = "Test output for ingress_rules"
  value       = module.security_group_test.ingress_rules
}

output "test_egress_rules" {
  description = "Test output for egress_rules"
  value       = module.security_group_test.egress_rules
}

output "test_ingress_rules_count" {
  description = "Test output for ingress_rules_count"
  value       = module.security_group_test.ingress_rules_count
}

output "test_egress_rules_count" {
  description = "Test output for egress_rules_count"
  value       = module.security_group_test.egress_rules_count
}

output "test_ingress_security_group_rules" {
  description = "Test output for ingress_security_group_rules"
  value       = module.security_group_test.ingress_security_group_rules
}

output "test_egress_security_group_rules" {
  description = "Test output for egress_security_group_rules"
  value       = module.security_group_test.egress_security_group_rules
}

output "test_flow_log" {
  description = "Test output for flow_log"
  value       = module.security_group_test.flow_log
}

output "test_tags_all" {
  description = "Test output for tags_all"
  value       = module.security_group_test.tags_all
}

output "test_resource_name" {
  description = "Test output for resource_name"
  value       = module.security_group_test.resource_name
}

output "test_security_group_tags" {
  description = "Test output for security_group_tags"
  value       = module.security_group_test.security_group_tags
}

output "test_security_controls_status" {
  description = "Test output for security_controls_status"
  value       = module.security_group_test.security_controls_status
}

output "test_security_compliance_tags" {
  description = "Test output for security_compliance_tags"
  value       = module.security_group_test.security_compliance_tags
}

output "test_security_group_summary" {
  description = "Test output for security_group_summary"
  value       = module.security_group_test.security_group_summary
}

output "test_rule_analysis" {
  description = "Test output for rule_analysis"
  value       = module.security_group_test.rule_analysis
}

output "test_validation_results" {
  description = "Test output for validation_results"
  value       = module.security_group_test.validation_results
}
