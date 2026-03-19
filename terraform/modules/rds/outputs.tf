# Terraform AWS RDS Module - Outputs
# L1 Module outputs following CCMS standards

#------------------------------------------------------------------------------
# RDS INSTANCE OUTPUTS
#------------------------------------------------------------------------------

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.this.identifier
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.this.resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.this.status
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_instance_engine" {
  description = "The database engine"
  value       = aws_db_instance.this.engine
}

output "db_instance_engine_version" {
  description = "The running version of the database"
  value       = aws_db_instance.this.engine_version_actual
}

output "db_instance_class" {
  description = "The RDS instance class"
  value       = aws_db_instance.this.instance_class
}

#------------------------------------------------------------------------------
# NETWORK OUTPUTS
#------------------------------------------------------------------------------

output "db_instance_address" {
  description = "The RDS instance hostname"
  value       = aws_db_instance.this.address
}

output "db_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance"
  value       = aws_db_instance.this.hosted_zone_id
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.this.availability_zone
}

output "db_instance_multi_az" {
  description = "If the RDS instance is multi AZ enabled"
  value       = aws_db_instance.this.multi_az
}

#------------------------------------------------------------------------------
# SUBNET GROUP OUTPUTS
#------------------------------------------------------------------------------

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = var.db_subnet_group_name != null ? var.db_subnet_group_name : aws_db_subnet_group.this[0].id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = var.db_subnet_group_name != null ? null : aws_db_subnet_group.this[0].arn
}

#------------------------------------------------------------------------------
# PARAMETER GROUP OUTPUTS
#------------------------------------------------------------------------------

output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = var.parameter_group_name != null ? var.parameter_group_name : aws_db_parameter_group.this[0].id
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = var.parameter_group_name != null ? null : aws_db_parameter_group.this[0].arn
}

#------------------------------------------------------------------------------
# OPTION GROUP OUTPUTS
#------------------------------------------------------------------------------

output "db_option_group_id" {
  description = "The db option group id"
  value       = var.option_group_name != null ? var.option_group_name : (
    var.major_engine_version != null ? aws_db_option_group.this[0].id : null
  )
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = var.option_group_name != null ? null : (
    var.major_engine_version != null ? aws_db_option_group.this[0].arn : null
  )
}

#------------------------------------------------------------------------------
# STORAGE OUTPUTS
#------------------------------------------------------------------------------

output "db_instance_allocated_storage" {
  description = "The amount of allocated storage"
  value       = aws_db_instance.this.allocated_storage
}

output "db_instance_max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage"
  value       = aws_db_instance.this.max_allocated_storage
}

output "db_instance_storage_type" {
  description = "The storage type of the RDS instance"
  value       = aws_db_instance.this.storage_type
}

output "db_instance_storage_encrypted" {
  description = "Whether the DB instance is encrypted"
  value       = aws_db_instance.this.storage_encrypted
}

output "db_instance_kms_key_id" {
  description = "The ARN for the KMS encryption key"
  value       = aws_db_instance.this.kms_key_id
}

#------------------------------------------------------------------------------
# BACKUP OUTPUTS
#------------------------------------------------------------------------------

output "db_instance_backup_retention_period" {
  description = "The backup retention period"
  value       = aws_db_instance.this.backup_retention_period
}

output "db_instance_backup_window" {
  description = "The backup window"
  value       = aws_db_instance.this.backup_window
}

output "db_instance_maintenance_window" {
  description = "The instance maintenance window"
  value       = aws_db_instance.this.maintenance_window
}

#------------------------------------------------------------------------------
# READ REPLICA OUTPUTS
#------------------------------------------------------------------------------

output "read_replica_id" {
  description = "The RDS read replica instance ID"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].id : null
}

output "read_replica_arn" {
  description = "The ARN of the RDS read replica instance"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].arn : null
}

output "read_replica_endpoint" {
  description = "The RDS read replica instance endpoint"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].endpoint : null
}

#------------------------------------------------------------------------------
# MONITORING OUTPUTS
#------------------------------------------------------------------------------

output "db_instance_monitoring_interval" {
  description = "The interval for collecting enhanced monitoring metrics"
  value       = aws_db_instance.this.monitoring_interval
}

output "db_instance_monitoring_role_arn" {
  description = "The ARN for the IAM role for enhanced monitoring"
  value       = aws_db_instance.this.monitoring_role_arn
}

output "performance_insights_enabled" {
  description = "Whether Performance Insights is enabled"
  value       = aws_db_instance.this.performance_insights_enabled
}

output "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  value       = aws_db_instance.this.performance_insights_kms_key_id
}

output "cloudwatch_alarms" {
  description = "CloudWatch alarms created for the RDS instance"
  value = var.enable_cloudwatch_alarms ? {
    cpu_utilization = {
      alarm_name = try(aws_cloudwatch_metric_alarm.database_cpu[0].alarm_name, null)
      alarm_arn  = try(aws_cloudwatch_metric_alarm.database_cpu[0].arn, null)
    }
    database_connections = {
      alarm_name = try(aws_cloudwatch_metric_alarm.database_connections[0].alarm_name, null)
      alarm_arn  = try(aws_cloudwatch_metric_alarm.database_connections[0].arn, null)
    }
    freeable_memory = {
      alarm_name = try(aws_cloudwatch_metric_alarm.database_freeable_memory[0].alarm_name, null)
      alarm_arn  = try(aws_cloudwatch_metric_alarm.database_freeable_memory[0].arn, null)
    }
  } : {}
}

#------------------------------------------------------------------------------
# SECURITY OUTPUTS
#------------------------------------------------------------------------------

output "db_instance_deletion_protection" {
  description = "Whether deletion protection is enabled"
  value       = aws_db_instance.this.deletion_protection
}

output "security_controls_status" {
  description = "Status of implemented security controls"
  value = var.security_controls_enabled ? {
    rds_01_tagging = {
      control = "RDS Tagging Compliance"
      status  = "COMPLIANT"
      details = "All required tags applied to RDS instance"
    }
    rds_02_encryption = {
      control = "Encryption at Rest"
      status  = local.encryption_validation
      details = "Storage encryption validation status"
    }
    rds_03_backup_retention = {
      control = "Backup and Recovery"
      status  = local.backup_validation
      details = "Backup retention validation status"
    }
    rds_04_multi_az = {
      control = "Multi-AZ Deployment"
      status  = local.multi_az_validation
      details = "Multi-AZ deployment validation status"
    }
    rds_05_monitoring = {
      control = "Enhanced Monitoring"
      status  = local.monitoring_validation
      details = "Enhanced monitoring validation status"
    }
    rds_06_performance_insights = {
      control = "Performance Monitoring"
      status  = local.performance_insights_validation
      details = "Performance Insights validation status"
    }
    rds_07_deletion_protection = {
      control = "Deletion Protection"
      status  = local.deletion_protection_validation
      details = "Deletion protection validation status"
    }
  } : {}
}

#------------------------------------------------------------------------------
# TAGGING OUTPUTS (CCMS COMPLIANCE)
#------------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the RDS instance including default provider tags"
  value       = aws_db_instance.this.tags_all
}

output "resource_name" {
  description = "Resource name used for the RDS instance"
  value       = var.resource_name
}

output "db_instance_tags" {
  description = "Tags applied specifically to the RDS instance resource"
  value       = aws_db_instance.this.tags
}

#------------------------------------------------------------------------------
# COMPUTED OUTPUTS
#------------------------------------------------------------------------------

output "db_instance_summary" {
  description = "Summary of RDS instance configuration"
  value = {
    identifier            = aws_db_instance.this.identifier
    engine               = aws_db_instance.this.engine
    engine_version       = aws_db_instance.this.engine_version_actual
    instance_class       = aws_db_instance.this.instance_class
    allocated_storage    = aws_db_instance.this.allocated_storage
    storage_encrypted    = aws_db_instance.this.storage_encrypted
    multi_az            = aws_db_instance.this.multi_az
    publicly_accessible = aws_db_instance.this.publicly_accessible
    deletion_protection = aws_db_instance.this.deletion_protection
    backup_retention    = aws_db_instance.this.backup_retention_period
    environment         = var.environment
  }
}

output "connection_info" {
  description = "Database connection information"
  value = {
    endpoint = aws_db_instance.this.endpoint
    port     = aws_db_instance.this.port
    database = aws_db_instance.this.db_name
    username = aws_db_instance.this.username
  }
  sensitive = true
}

#------------------------------------------------------------------------------
# VALIDATION OUTPUTS
#------------------------------------------------------------------------------

output "validation_results" {
  description = "Security validation results"
  value = {
    encryption_validation            = local.encryption_validation
    backup_validation               = local.backup_validation
    multi_az_validation             = local.multi_az_validation
    monitoring_validation           = local.monitoring_validation
    performance_insights_validation = local.performance_insights_validation
    deletion_protection_validation  = local.deletion_protection_validation
    overall_compliance              = alltrue([
      local.encryption_validation != "NON_COMPLIANT",
      local.backup_validation != "NON_COMPLIANT",
      local.multi_az_validation != "NON_COMPLIANT",
      local.monitoring_validation != "NON_COMPLIANT",
      local.performance_insights_validation != "NON_COMPLIANT",
      local.deletion_protection_validation != "NON_COMPLIANT"
    ]) ? "COMPLIANT" : "NON_COMPLIANT"
  }
}