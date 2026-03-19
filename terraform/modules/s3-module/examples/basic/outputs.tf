# Outputs for S3 Basic Example

output "s3-module_id" {
  description = "The ID of the S3"
  value       = module.s3-module_basic.s3-module_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.s3-module_basic.security_controls_status
}