# Terraform AWS Security Group Module - Variables
# Comprehensive variable definitions for Security Group module

variable "resource_name" {
  description = "Name tag for the Security Group resource"
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

variable "name_prefix" {
  description = "Name prefix for the security group (creates unique names)"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Security group managed by Terraform"
  validation {
    condition     = length(var.description) > 0 && length(var.description) <= 255
    error_message = "Description must be between 1 and 255 characters."
  }
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8,17}$", var.vpc_id))
    error_message = "VPC ID must be valid (vpc-xxxxxxxx format)."
  }
}

# Ingress Rules Configuration
variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description      = optional(string)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    prefix_list_ids  = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
  }))
  default = []
  
  validation {
    condition = alltrue([
      for rule in var.ingress_rules : 
      rule.from_port >= 0 && rule.from_port <= 65535 &&
      rule.to_port >= 0 && rule.to_port <= 65535 &&
      rule.from_port <= rule.to_port
    ])
    error_message = "Port numbers must be between 0 and 65535, and from_port must be <= to_port."
  }
}

# Egress Rules Configuration
variable "egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    description      = optional(string)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    prefix_list_ids  = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
  }))
  default = [
    {
      description = "All outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  validation {
    condition = alltrue([
      for rule in var.egress_rules : 
      rule.from_port >= 0 && rule.from_port <= 65535 &&
      rule.to_port >= 0 && rule.to_port <= 65535 &&
      rule.from_port <= rule.to_port
    ])
    error_message = "Port numbers must be between 0 and 65535, and from_port must be <= to_port."
  }
}

# Advanced Rules with Security Group References
variable "ingress_with_source_security_group_id" {
  description = "List of ingress rules with source security group IDs"
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    source_security_group_id = string
  }))
  default = []
  
  validation {
    condition = alltrue([
      for rule in var.ingress_with_source_security_group_id : 
      can(regex("^sg-[a-f0-9]{8,17}$", rule.source_security_group_id))
    ])
    error_message = "All source security group IDs must be valid (sg-xxxxxxxx format)."
  }
}

variable "egress_with_source_security_group_id" {
  description = "List of egress rules with source security group IDs"
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    source_security_group_id = string
  }))
  default = []
  
  validation {
    condition = alltrue([
      for rule in var.egress_with_source_security_group_id : 
      can(regex("^sg-[a-f0-9]{8,17}$", rule.source_security_group_id))
    ])
    error_message = "All source security group IDs must be valid (sg-xxxxxxxx format)."
  }
}

# Security Configuration
variable "restrict_ssh_access" {
  description = "Whether to restrict SSH access from 0.0.0.0/0"
  type        = bool
  default     = true
}

variable "require_rule_descriptions" {
  description = "Whether to require descriptions for all rules"
  type        = bool
  default     = true
}

variable "block_all_outbound_default" {
  description = "Whether to block all outbound traffic by default"
  type        = bool
  default     = false
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

# Flow Logs Configuration
variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs for monitoring"
  type        = bool
  default     = false
}

variable "flow_log_iam_role_arn" {
  description = "IAM role ARN for VPC Flow Logs"
  type        = string
  default     = null
}

variable "flow_log_destination_arn" {
  description = "Destination ARN for VPC Flow Logs (CloudWatch Logs or S3)"
  type        = string
  default     = null
}

variable "flow_log_traffic_type" {
  description = "Type of traffic to capture in flow logs"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_log_traffic_type)
    error_message = "Flow log traffic type must be one of: ACCEPT, REJECT, ALL."
  }
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
  default     = "security-group-project"
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
  default     = "security-group-application"
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