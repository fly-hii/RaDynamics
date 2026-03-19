# Variables for Standalone EC2 Example

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "resource_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "standalone-ec2-example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# CCMS compliance variables
variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ec2-standalone-example"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "platform-team"
}

variable "business_unit" {
  description = "Business unit"
  type        = string
  default     = "engineering"
}

variable "application_name" {
  description = "Application name"
  type        = string
  default     = "standalone-demo"
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
}