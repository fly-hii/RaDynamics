# ALB Module Basic Example

This example demonstrates the basic usage of the ALB module with minimal configuration.

## Usage

```hcl
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
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID where the ALB will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the ALB | `list(string)` | n/a | yes |
| aws_region | AWS region for deployment | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_id | The ID of the Application Load Balancer |
| alb_arn | The ARN of the Application Load Balancer |
| alb_dns_name | The DNS name of the Application Load Balancer |
| alb_zone_id | The canonical hosted zone ID of the Application Load Balancer |
| security_controls_status | Status of security controls implementation |