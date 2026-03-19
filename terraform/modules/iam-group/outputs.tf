# IAM Group Outputs

output "group_name" {
  description = "Name of the created IAM group"
  value       = aws_iam_group.group.name
}

output "group_arn" {
  description = "ARN of the created IAM group"
  value       = aws_iam_group.group.arn
}

output "group_path" {
  description = "Path of the created IAM group"
  value       = aws_iam_group.group.path
}

output "group_unique_id" {
  description = "Unique ID of the created IAM group"
  value       = aws_iam_group.group.unique_id
}

output "attached_policies" {
  description = "List of attached policy ARNs"
  value       = var.attached_policies
}