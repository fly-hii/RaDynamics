# Basic Elastic Container Service Module Example
# This example demonstrates the minimal configuration required for the Elastic Container Service module

module "ecs_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-ecs"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "ecs-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "Elastic Container Service Example"
  }
}