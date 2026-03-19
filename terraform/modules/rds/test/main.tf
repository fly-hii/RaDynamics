
# Test configuration for rds module
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
module "rds_test" {
  source = "../"
  
  identifier = "test-rds-deployment"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  db_name = "testdb"
  username = "admin"
  password = "testpassword123"
  vpc_security_group_ids = ["sg-12345678"]
  db_subnet_group_name = "test-subnet-group"
  backup_retention_period = 7
  backup_window = "03:00-04:00"
  maintenance_window = "sun:04:00-sun:05:00"
  skip_final_snapshot = true
  tags = {"Environment":"test","Purpose":"deployment-validation"}
}

# Output the module outputs
output "test_db_instance_id" {
  description = "Test output for db_instance_id"
  value       = module.rds_test.db_instance_id
}

output "test_db_instance_arn" {
  description = "Test output for db_instance_arn"
  value       = module.rds_test.db_instance_arn
}

output "test_db_instance_identifier" {
  description = "Test output for db_instance_identifier"
  value       = module.rds_test.db_instance_identifier
}

output "test_db_instance_resource_id" {
  description = "Test output for db_instance_resource_id"
  value       = module.rds_test.db_instance_resource_id
}

output "test_db_instance_status" {
  description = "Test output for db_instance_status"
  value       = module.rds_test.db_instance_status
}

output "test_db_instance_name" {
  description = "Test output for db_instance_name"
  value       = module.rds_test.db_instance_name
}

output "test_db_instance_username" {
  description = "Test output for db_instance_username"
  value       = module.rds_test.db_instance_username
}

output "test_db_instance_engine" {
  description = "Test output for db_instance_engine"
  value       = module.rds_test.db_instance_engine
}

output "test_db_instance_engine_version" {
  description = "Test output for db_instance_engine_version"
  value       = module.rds_test.db_instance_engine_version
}

output "test_db_instance_class" {
  description = "Test output for db_instance_class"
  value       = module.rds_test.db_instance_class
}

output "test_db_instance_address" {
  description = "Test output for db_instance_address"
  value       = module.rds_test.db_instance_address
}

output "test_db_instance_endpoint" {
  description = "Test output for db_instance_endpoint"
  value       = module.rds_test.db_instance_endpoint
}

output "test_db_instance_hosted_zone_id" {
  description = "Test output for db_instance_hosted_zone_id"
  value       = module.rds_test.db_instance_hosted_zone_id
}

output "test_db_instance_port" {
  description = "Test output for db_instance_port"
  value       = module.rds_test.db_instance_port
}

output "test_db_instance_availability_zone" {
  description = "Test output for db_instance_availability_zone"
  value       = module.rds_test.db_instance_availability_zone
}

output "test_db_instance_multi_az" {
  description = "Test output for db_instance_multi_az"
  value       = module.rds_test.db_instance_multi_az
}

output "test_db_subnet_group_id" {
  description = "Test output for db_subnet_group_id"
  value       = module.rds_test.db_subnet_group_id
}

output "test_db_subnet_group_arn" {
  description = "Test output for db_subnet_group_arn"
  value       = module.rds_test.db_subnet_group_arn
}

output "test_db_parameter_group_id" {
  description = "Test output for db_parameter_group_id"
  value       = module.rds_test.db_parameter_group_id
}

output "test_db_parameter_group_arn" {
  description = "Test output for db_parameter_group_arn"
  value       = module.rds_test.db_parameter_group_arn
}

output "test_db_option_group_id" {
  description = "Test output for db_option_group_id"
  value       = module.rds_test.db_option_group_id
}

output "test_db_option_group_arn" {
  description = "Test output for db_option_group_arn"
  value       = module.rds_test.db_option_group_arn
}

output "test_db_instance_allocated_storage" {
  description = "Test output for db_instance_allocated_storage"
  value       = module.rds_test.db_instance_allocated_storage
}

output "test_db_instance_max_allocated_storage" {
  description = "Test output for db_instance_max_allocated_storage"
  value       = module.rds_test.db_instance_max_allocated_storage
}

output "test_db_instance_storage_type" {
  description = "Test output for db_instance_storage_type"
  value       = module.rds_test.db_instance_storage_type
}

output "test_db_instance_storage_encrypted" {
  description = "Test output for db_instance_storage_encrypted"
  value       = module.rds_test.db_instance_storage_encrypted
}

output "test_db_instance_kms_key_id" {
  description = "Test output for db_instance_kms_key_id"
  value       = module.rds_test.db_instance_kms_key_id
}

output "test_db_instance_backup_retention_period" {
  description = "Test output for db_instance_backup_retention_period"
  value       = module.rds_test.db_instance_backup_retention_period
}

output "test_db_instance_backup_window" {
  description = "Test output for db_instance_backup_window"
  value       = module.rds_test.db_instance_backup_window
}

output "test_db_instance_maintenance_window" {
  description = "Test output for db_instance_maintenance_window"
  value       = module.rds_test.db_instance_maintenance_window
}

output "test_read_replica_id" {
  description = "Test output for read_replica_id"
  value       = module.rds_test.read_replica_id
}

output "test_read_replica_arn" {
  description = "Test output for read_replica_arn"
  value       = module.rds_test.read_replica_arn
}

output "test_read_replica_endpoint" {
  description = "Test output for read_replica_endpoint"
  value       = module.rds_test.read_replica_endpoint
}

output "test_db_instance_monitoring_interval" {
  description = "Test output for db_instance_monitoring_interval"
  value       = module.rds_test.db_instance_monitoring_interval
}

output "test_db_instance_monitoring_role_arn" {
  description = "Test output for db_instance_monitoring_role_arn"
  value       = module.rds_test.db_instance_monitoring_role_arn
}

output "test_performance_insights_enabled" {
  description = "Test output for performance_insights_enabled"
  value       = module.rds_test.performance_insights_enabled
}

output "test_performance_insights_kms_key_id" {
  description = "Test output for performance_insights_kms_key_id"
  value       = module.rds_test.performance_insights_kms_key_id
}

output "test_cloudwatch_alarms" {
  description = "Test output for cloudwatch_alarms"
  value       = module.rds_test.cloudwatch_alarms
}

output "test_db_instance_deletion_protection" {
  description = "Test output for db_instance_deletion_protection"
  value       = module.rds_test.db_instance_deletion_protection
}

output "test_security_controls_status" {
  description = "Test output for security_controls_status"
  value       = module.rds_test.security_controls_status
}

output "test_tags_all" {
  description = "Test output for tags_all"
  value       = module.rds_test.tags_all
}

output "test_resource_name" {
  description = "Test output for resource_name"
  value       = module.rds_test.resource_name
}

output "test_db_instance_tags" {
  description = "Test output for db_instance_tags"
  value       = module.rds_test.db_instance_tags
}

output "test_db_instance_summary" {
  description = "Test output for db_instance_summary"
  value       = module.rds_test.db_instance_summary
}

output "test_connection_info" {
  description = "Test output for connection_info"
  value       = module.rds_test.connection_info
}

output "test_validation_results" {
  description = "Test output for validation_results"
  value       = module.rds_test.validation_results
}
