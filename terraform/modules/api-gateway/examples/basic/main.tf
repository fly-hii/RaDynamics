# Basic API Gateway Module Example
# This example demonstrates the minimal configuration required for the API Gateway module

module "api_gateway_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-api-gateway"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "api-gateway-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "API Gateway Example"
  }
}