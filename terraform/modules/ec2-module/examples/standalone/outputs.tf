# Outputs for Standalone EC2 Example

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "instance_arn" {
  description = "ARN of the created EC2 instance"
  value       = module.ec2_instance.instance_arn
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2_instance.private_ip
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.ec2_sg.id
}

output "security_controls_status" {
  description = "Status of security controls"
  value       = module.ec2_instance.security_controls_status
}