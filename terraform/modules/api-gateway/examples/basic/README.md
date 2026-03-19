# API Gateway Module Basic Example

This example demonstrates the basic usage of the API Gateway module with minimal configuration.

## Usage

```hcl
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
| aws_region | AWS region for deployment | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_gateway_id | The ID of the API Gateway |
| api_gateway_arn | The ARN of the API Gateway |
| api_gateway_execution_arn | The execution ARN of the API Gateway |
| security_controls_status | Status of security controls implementation |