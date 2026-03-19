# Terraform AWS EC2 Module - Variables
# Comprehensive variable definitions for EC2 module

variable "resource_name" {
  description = "Name tag for the EC2 instance resource"
  type        = string
  validation {
    condition     = length(var.resource_name) > 0 && length(var.resource_name) <= 255
    error_message = "Resource name must be between 1 and 255 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, test, staging, prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  validation {
    condition = can(regex("^[a-z][0-9][a-z]?\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge)$", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to associate with the instance"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for sg in var.vpc_security_group_ids : can(regex("^sg-[a-f0-9]{8,17}$", sg))
    ])
    error_message = "All security group IDs must be valid (sg-xxxxxxxx format)."
  }
}

variable "subnet_id" {
  description = "VPC subnet ID to launch the instance in"
  type        = string
  default     = null
  validation {
    condition = var.subnet_id == null || can(regex("^subnet-[a-f0-9]{8,17}$", var.subnet_id))
    error_message = "Subnet ID must be valid (subnet-xxxxxxxx format) or null."
  }
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
  default     = null
  validation {
    condition = var.ami_id == null || can(regex("^ami-[a-f0-9]{8,17}$", var.ami_id))
    error_message = "AMI ID must be valid (ami-xxxxxxxx format) or null."
  }
}

variable "ami_owners" {
  description = "List of AMI owners to limit search"
  type        = list(string)
  default     = ["amazon"]
}

variable "ami_name_filters" {
  description = "List of AMI name patterns to search for"
  type        = list(string)
  default     = ["amzn2-ami-hvm-*-x86_64-gp2"]
}

variable "availability_zone" {
  description = "Availability zone for the instance"
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to associate with the instance"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "user_data_template" {
  description = "Name of the user data template file in templates/ directory"
  type        = string
  default     = null
}

variable "user_data_variables" {
  description = "Variables to pass to the user data template"
  type        = map(string)
  default     = {}
}

# Storage Configuration
variable "root_block_device_volume_type" {
  description = "Type of volume for the root block device"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1"], var.root_block_device_volume_type)
    error_message = "Volume type must be one of: gp2, gp3, io1, io2, sc1, st1."
  }
}

variable "root_block_device_volume_size" {
  description = "Size of the root block device in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.root_block_device_volume_size >= 8 && var.root_block_device_volume_size <= 16384
    error_message = "Root volume size must be between 8 and 16384 GB."
  }
}

variable "root_block_device_iops" {
  description = "IOPS for the root block device"
  type        = number
  default     = null
}

variable "root_block_device_throughput" {
  description = "Throughput for the root block device in MB/s"
  type        = number
  default     = null
}

variable "root_block_device_encrypted" {
  description = "Whether to encrypt the root block device"
  type        = bool
  default     = true
}

variable "root_block_device_kms_key_id" {
  description = "KMS key ID for root block device encryption"
  type        = string
  default     = null
}

variable "root_block_device_delete_on_termination" {
  description = "Whether to delete the root block device on instance termination"
  type        = bool
  default     = true
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices to attach to the instance"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool)
    tags                  = optional(map(string))
  }))
  default = []
}

# Network Configuration
variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address to associate with the instance"
  type        = string
  default     = null
  validation {
    condition = var.private_ip == null || can(cidrhost("10.0.0.0/8", 0)) || can(cidrhost("172.16.0.0/12", 0)) || can(cidrhost("192.168.0.0/16", 0))
    error_message = "Private IP must be a valid private IP address or null."
  }
}

variable "secondary_private_ips" {
  description = "List of secondary private IP addresses"
  type        = list(string)
  default     = []
}

# Monitoring Configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for the instance"
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "Enable EC2 Instance Termination Protection"
  type        = bool
  default     = false
}

variable "disable_api_stop" {
  description = "Enable EC2 Instance Stop Protection"
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  type        = string
  default     = "stop"
  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "Shutdown behavior must be either 'stop' or 'terminate'."
  }
}

# Placement Configuration
variable "placement_group" {
  description = "Placement group for the instance"
  type        = string
  default     = null
}

variable "placement_partition_number" {
  description = "Number of the partition the instance should launch in"
  type        = number
  default     = null
}

variable "tenancy" {
  description = "Tenancy of the instance"
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "Tenancy must be one of: default, dedicated, host."
  }
}

variable "host_id" {
  description = "ID of a dedicated host that the instance will be assigned to"
  type        = string
  default     = null
}

variable "cpu_credits" {
  description = "Credit option for CPU usage"
  type        = string
  default     = null
}

# Metadata Configuration
variable "metadata_options_http_endpoint" {
  description = "Whether the metadata service is available"
  type        = string
  default     = "enabled"
  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_options_http_endpoint)
    error_message = "Metadata HTTP endpoint must be either 'enabled' or 'disabled'."
  }
}

variable "metadata_options_http_tokens" {
  description = "Whether or not the metadata service requires session tokens"
  type        = string
  default     = "required"
  validation {
    condition     = contains(["optional", "required"], var.metadata_options_http_tokens)
    error_message = "Metadata HTTP tokens must be either 'optional' or 'required'."
  }
}

variable "metadata_options_http_put_response_hop_limit" {
  description = "Desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
  validation {
    condition     = var.metadata_options_http_put_response_hop_limit >= 1 && var.metadata_options_http_put_response_hop_limit <= 64
    error_message = "HTTP PUT response hop limit must be between 1 and 64."
  }
}

variable "metadata_options_instance_metadata_tags" {
  description = "Enables or disables access to instance tags from the instance metadata service"
  type        = string
  default     = "disabled"
  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_options_instance_metadata_tags)
    error_message = "Instance metadata tags must be either 'enabled' or 'disabled'."
  }
}

variable "enable_nitro_enclaves" {
  description = "Whether to enable Nitro Enclaves"
  type        = bool
  default     = false
}

# Elastic IP Configuration
variable "associate_elastic_ip" {
  description = "Whether to associate an Elastic IP with the instance"
  type        = bool
  default     = false
}

variable "elastic_ip_allocation_id" {
  description = "Allocation ID of the Elastic IP to associate"
  type        = string
  default     = null
}

# CloudWatch Configuration
variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = false
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
  validation {
    condition     = var.cpu_utilization_threshold >= 1 && var.cpu_utilization_threshold <= 100
    error_message = "CPU utilization threshold must be between 1 and 100."
  }
}

variable "alarm_actions" {
  description = "List of alarm actions"
  type        = list(string)
  default     = []
}

# Security Configuration
variable "require_encryption" {
  description = "Whether to require encryption for all EBS volumes"
  type        = bool
  default     = true
}

variable "enforce_imdsv2" {
  description = "Whether to enforce IMDSv2"
  type        = bool
  default     = true
}

variable "enable_termination_protection_prod" {
  description = "Whether to enable termination protection in production"
  type        = bool
  default     = true
}

variable "security_controls_enabled" {
  description = "Whether to enable security controls validation"
  type        = bool
  default     = true
}

variable "security_compliance_tags" {
  description = "Security compliance tags"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to be merged with core tags"
  type        = map(string)
  default     = {}
}

# CCMS compliance variables
variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "default-cost-center"
}

variable "project_name" {
  description = "Project name for resource organization"
  type        = string
  default     = "ec2-project"
}

variable "owner" {
  description = "Resource owner for accountability"
  type        = string
  default     = "terraform-user"
}

variable "business_unit" {
  description = "Business unit responsible for the resource"
  type        = string
  default     = "engineering"
}

variable "application_name" {
  description = "Application name for resource categorization"
  type        = string
  default     = "ec2-application"
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}