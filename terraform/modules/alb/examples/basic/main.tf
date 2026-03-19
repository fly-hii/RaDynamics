# Basic ALB Module Example
# This example demonstrates the minimal configuration required for the ALB module

module "alb_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-alb"
  environment   = "dev"
  
  # VPC and networking
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "alb-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "ALB Example"
  }
}