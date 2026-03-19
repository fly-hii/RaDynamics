# Outputs for Basic EC2 Example

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = module.basic_ec2_instance.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.basic_ec2_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.basic_ec2_instance.private_ip
}

output "instance_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.basic_ec2_instance.public_dns
}