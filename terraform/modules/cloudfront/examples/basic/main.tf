# Basic CloudFront Module Example
# This example demonstrates the minimal configuration required for the CloudFront module

module "cloudfront_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-cloudfront"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "cloudfront-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "CloudFront Example"
  }
}