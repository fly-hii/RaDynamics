# Outputs for CloudFront Basic Example

output "cloudfront_id" {
  description = "The ID of the CloudFront"
  value       = module.cloudfront_basic.cloudfront_id
}

output "security_controls_status" {
  description = "Status of security controls implementation"
  value       = module.cloudfront_basic.security_controls_status
}