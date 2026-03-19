# IAM Group Terraform Module
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM Group
resource "aws_iam_group" "group" {
  name = var.group_name
  path = var.path
}

# Attach AWS Managed Policies
resource "aws_iam_group_policy_attachment" "aws_managed_policies" {
  for_each = toset(var.attached_policies)
  
  group      = aws_iam_group.group.name
  policy_arn = each.value
}

# Group Tags (if supported by provider version)
resource "aws_iam_group" "group_with_tags" {
  count = length(var.additional_tags) > 0 ? 1 : 0
  
  name = var.group_name
  path = var.path
  
  tags = var.additional_tags
}