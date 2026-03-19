# Basic Lambda Module Example
# This example demonstrates the minimal configuration required for the Lambda module

module "lambda_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-lambda"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "lambda-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "Lambda Example"
  }
}