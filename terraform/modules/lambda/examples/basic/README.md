# Lambda Module Basic Example

This example demonstrates the basic usage of the Lambda module with minimal configuration.

## Usage

```hcl
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
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |