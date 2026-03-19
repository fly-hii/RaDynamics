# Terraform AWS EC2 Module - Outputs
# L1 Module outputs following CCMS standards

#------------------------------------------------------------------------------
# INSTANCE OUTPUTS
#------------------------------------------------------------------------------

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.this.instance_state
}

output "instance_type" {
  description = "Type of the EC2 instance"
  value       = aws_instance.this.instance_type
}

output "ami_id" {
  description = "AMI ID used for the EC2 instance"
  value       = aws_instance.this.ami
}

output "key_name" {
  description = "Key name associated with the EC2 instance"
  value       = aws_instance.this.key_name
}

#------------------------------------------------------------------------------
# NETWORK OUTPUTS
#------------------------------------------------------------------------------

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance (if applicable)"
  value       = aws_instance.this.public_ip
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance"
  value       = aws_instance.this.private_dns
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance (if applicable)"
  value       = aws_instance.this.public_dns
}

output "subnet_id" {
  description = "Subnet ID where the EC2 instance is launched"
  value       = aws_instance.this.subnet_id
}

output "vpc_security_group_ids" {
  description = "List of VPC security group IDs associated with the instance"
  value       = aws_instance.this.vpc_security_group_ids
}

output "availability_zone" {
  description = "Availability zone where the EC2 instance is launched"
  value       = aws_instance.this.availability_zone
}

output "placement_group" {
  description = "Placement group of the EC2 instance"
  value       = aws_instance.this.placement_group
}

#------------------------------------------------------------------------------
# STORAGE OUTPUTS
#------------------------------------------------------------------------------

output "root_block_device" {
  description = "Root block device information"
  value = {
    device_name           = try(aws_instance.this.root_block_device[0].device_name, null)
    volume_id             = try(aws_instance.this.root_block_device[0].volume_id, null)
    volume_size           = try(aws_instance.this.root_block_device[0].volume_size, null)
    volume_type           = try(aws_instance.this.root_block_device[0].volume_type, null)
    iops                  = try(aws_instance.this.root_block_device[0].iops, null)
    throughput            = try(aws_instance.this.root_block_device[0].throughput, null)
    encrypted             = try(aws_instance.this.root_block_device[0].encrypted, null)
    kms_key_id            = try(aws_instance.this.root_block_device[0].kms_key_id, null)
    delete_on_termination = try(aws_instance.this.root_block_device[0].delete_on_termination, null)
  }
}

output "ebs_block_devices" {
  description = "EBS block device information"
  value = [
    for device in aws_instance.this.ebs_block_device : {
      device_name           = device.device_name
      volume_id             = device.volume_id
      volume_size           = device.volume_size
      volume_type           = device.volume_type
      iops                  = device.iops
      throughput            = device.throughput
      encrypted             = device.encrypted
      kms_key_id            = device.kms_key_id
      delete_on_termination = device.delete_on_termination
    }
  ]
}

#------------------------------------------------------------------------------
# MONITORING OUTPUTS
#------------------------------------------------------------------------------

output "monitoring" {
  description = "Whether detailed monitoring is enabled for the instance"
  value       = aws_instance.this.monitoring
}

output "cloudwatch_alarms" {
  description = "CloudWatch alarms created for the instance"
  value = var.enable_cloudwatch_alarms ? {
    cpu_utilization = {
      alarm_name = try(aws_cloudwatch_metric_alarm.cpu_utilization[0].alarm_name, null)
      alarm_arn  = try(aws_cloudwatch_metric_alarm.cpu_utilization[0].arn, null)
    }
    status_check = {
      alarm_name = try(aws_cloudwatch_metric_alarm.status_check[0].alarm_name, null)
      alarm_arn  = try(aws_cloudwatch_metric_alarm.status_check[0].arn, null)
    }
  } : {}
}

#------------------------------------------------------------------------------
# IAM OUTPUTS
#------------------------------------------------------------------------------

output "iam_instance_profile" {
  description = "IAM instance profile associated with the instance"
  value       = aws_instance.this.iam_instance_profile
}

#------------------------------------------------------------------------------
# ELASTIC IP OUTPUTS
#------------------------------------------------------------------------------

output "elastic_ip_association" {
  description = "Elastic IP association information"
  value = var.associate_elastic_ip && var.elastic_ip_allocation_id != null ? {
    id            = try(aws_eip_association.this[0].id, null)
    allocation_id = try(aws_eip_association.this[0].allocation_id, null)
    instance_id   = try(aws_eip_association.this[0].instance_id, null)
    public_ip     = try(aws_eip_association.this[0].public_ip, null)
  } : {}
}

#------------------------------------------------------------------------------
# METADATA OUTPUTS
#------------------------------------------------------------------------------

output "metadata_options" {
  description = "Metadata options for the instance"
  value = {
    http_endpoint               = aws_instance.this.metadata_options[0].http_endpoint
    http_tokens                 = aws_instance.this.metadata_options[0].http_tokens
    http_put_response_hop_limit = aws_instance.this.metadata_options[0].http_put_response_hop_limit
    instance_metadata_tags      = aws_instance.this.metadata_options[0].instance_metadata_tags
  }
}

#------------------------------------------------------------------------------
# SECURITY OUTPUTS
#------------------------------------------------------------------------------

output "disable_api_termination" {
  description = "Whether termination protection is enabled"
  value       = aws_instance.this.disable_api_termination
}

output "disable_api_stop" {
  description = "Whether stop protection is enabled"
  value       = aws_instance.this.disable_api_stop
}

#------------------------------------------------------------------------------
# TAGGING OUTPUTS (CCMS COMPLIANCE)
#------------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the instance including default provider tags"
  value       = aws_instance.this.tags_all
}

output "resource_name" {
  description = "Resource name used for the instance"
  value       = var.resource_name
}

#------------------------------------------------------------------------------
# COMPUTED OUTPUTS
#------------------------------------------------------------------------------

output "instance_lifecycle" {
  description = "Instance lifecycle information"
  value = {
    instance_initiated_shutdown_behavior = aws_instance.this.instance_initiated_shutdown_behavior
    tenancy                              = aws_instance.this.tenancy
    host_id                              = aws_instance.this.host_id
    cpu_credits                          = try(aws_instance.this.credit_specification[0].cpu_credits, null)
  }
}

output "network_interface_id" {
  description = "Primary network interface ID"
  value       = aws_instance.this.primary_network_interface_id
}

output "outpost_arn" {
  description = "ARN of the Outpost the instance is running on"
  value       = aws_instance.this.outpost_arn
}

output "password_data" {
  description = "Base-64 encoded encrypted password data for the instance"
  value       = aws_instance.this.password_data
  sensitive   = true
}

output "instance_tags" {
  description = "Tags applied specifically to the instance resource"
  value       = aws_instance.this.tags
}

#------------------------------------------------------------------------------
# SECURITY CONTROL OUTPUTS
#------------------------------------------------------------------------------

output "security_controls_status" {
  description = "Status of implemented security controls"
  value = var.security_controls_enabled ? {
    ec2_01_encryption = {
      control = "EBS Encryption at Rest"
      status  = var.root_block_device_encrypted ? "COMPLIANT" : "NON_COMPLIANT"
      details = "Root and additional EBS volumes encryption status"
    }
    ec2_02_imdsv2 = {
      control = "Instance Metadata Service v2"
      status  = var.metadata_options_http_tokens == "required" ? "COMPLIANT" : "NON_COMPLIANT"
      details = "IMDSv2 enforcement for metadata security"
    }
    ec2_05_network_isolation = {
      control = "Private Network Isolation"
      status  = var.associate_public_ip_address == false ? "COMPLIANT" : "CONDITIONAL"
      details = "Public IP association status"
    }
    ec2_06_termination_protection = {
      control = "Termination Protection"
      status  = var.disable_api_termination ? "ENABLED" : "DISABLED"
      details = "Instance termination protection status"
    }
    ec2_07_detailed_monitoring = {
      control = "CloudWatch Detailed Monitoring"
      status  = var.enable_detailed_monitoring ? "ENABLED" : "DISABLED"
      details = "Enhanced monitoring and alerting status"
    }
  } : {}
}

output "security_compliance_tags" {
  description = "Security compliance tags applied to the instance"
  value = {
    security_controls      = lookup(local.standard_tags, "SecurityControls", "")
    encryption_enabled     = lookup(local.standard_tags, "EncryptionEnabled", "")
    imdsv2_enforced        = lookup(local.standard_tags, "IMDSv2Enforced", "")
    termination_protection = lookup(local.standard_tags, "TerminationProtection", "")
    security_framework     = lookup(var.security_compliance_tags, "SecurityFramework", "")
    compliance_level       = lookup(var.security_compliance_tags, "ComplianceLevel", "")
  }
}

output "encryption_status" {
  description = "Encryption status for all storage volumes"
  value = {
    root_volume_encrypted = aws_instance.this.root_block_device[0].encrypted
    root_volume_kms_key   = aws_instance.this.root_block_device[0].kms_key_id
    additional_volumes_encrypted = [
      for device in aws_instance.this.ebs_block_device : {
        device_name = device.device_name
        encrypted   = device.encrypted
        kms_key_id  = device.kms_key_id
      }
    ]
  }
}