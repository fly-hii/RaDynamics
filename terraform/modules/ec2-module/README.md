# AWS EC2 Terraform Module

A comprehensive Terraform module for deploying AWS EC2 instances with enterprise-grade security controls, CCMS compliance, and monitoring capabilities.

## Features

- **Security Controls**: 19 built-in security controls including EBS encryption, IMDSv2 enforcement, and network isolation
- **CCMS Compliance**: Full compliance with Cloud Configuration Management Standards
- **Monitoring**: CloudWatch detailed monitoring and custom alarms
- **Templates**: Pre-built user data templates for common use cases
- **Flexibility**: Extensive configuration options for all EC2 features
- **Validation**: Built-in validation for security and compliance requirements

## Security Controls

This module implements the following security controls:

- **EC2-01**: EBS Encryption at Rest
- **EC2-02**: Instance Metadata Service v2 (IMDSv2) Enforcement
- **EC2-05**: Private Network Isolation
- **EC2-06**: Termination Protection
- **EC2-07**: CloudWatch Detailed Monitoring
- **EC2-09**: Security Monitoring and Alerting
- **EC2-15**: Resource Tagging Compliance

## Usage

### Basic Example

```hcl
module "ec2_instance" {
  source = "./modules/ec2-module"

  # Required variables
  resource_name = "my-web-server"
  environment   = "prod"

  # Instance configuration
  instance_type          = "t3.medium"
  key_name              = "my-key-pair"
  subnet_id             = "subnet-12345678"
  vpc_security_group_ids = ["sg-12345678"]

  # Security configuration
  root_block_device_encrypted = true
  metadata_options_http_tokens = "required"
  associate_public_ip_address = false

  # Monitoring
  enable_detailed_monitoring = true
  enable_cloudwatch_alarms   = true

  # CCMS compliance
  cost_center         = "engineering"
  project_name        = "web-application"
  owner              = "platform-team"
  business_unit      = "engineering"
  application_name   = "web-server"
  data_classification = "internal"
}
```

### Advanced Example with User Data Template

```hcl
module "web_server" {
  source = "./modules/ec2-module"

  resource_name = "web-application-server"
  environment   = "prod"

  # Instance configuration
  instance_type = "t3.large"
  key_name     = "web-server-key"

  # Network configuration
  subnet_id                   = "subnet-12345678"
  vpc_security_group_ids      = ["sg-12345678"]
  associate_public_ip_address = false

  # Storage configuration
  root_block_device_volume_size = 50
  root_block_device_volume_type = "gp3"
  root_block_device_encrypted   = true

  # User data template
  user_data_template = "web_application.tpl"
  user_data_variables = {
    app_name         = "my-web-app"
    environment      = "prod"
    aws_region       = "us-east-1"
    enable_monitoring = true
  }

  # Additional EBS volumes
  ebs_block_devices = [
    {
      device_name = "/dev/sdf"
      volume_size = 100
      volume_type = "gp3"
      encrypted   = true
    }
  ]

  # Security configuration
  metadata_options_http_tokens = "required"
  disable_api_termination     = true
  enable_detailed_monitoring  = true
  enable_cloudwatch_alarms    = true

  # CCMS compliance tags
  cost_center         = "engineering"
  project_name        = "web-platform"
  owner              = "platform-team"
  business_unit      = "engineering"
  application_name   = "web-application"
  data_classification = "confidential"

  # Additional tags
  additional_tags = {
    Backup     = "daily"
    Monitoring = "enhanced"
    Purpose    = "web-server"
  }
}
```

## User Data Templates

The module includes pre-built user data templates:

- **basic_linux.tpl**: Basic Linux setup with monitoring and health checks
- **web_application.tpl**: Web server setup with Apache and application structure

### Using Templates

```hcl
user_data_template = "basic_linux.tpl"
user_data_variables = {
  environment      = "prod"
  aws_region       = "us-east-1"
  resource_name    = "my-instance"
  enable_monitoring = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_name | Name tag for the EC2 instance resource | `string` | n/a | yes |
| environment | Environment name (dev, qa, prod) | `string` | n/a | yes |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| key_name | Name of the EC2 Key Pair | `string` | `null` | no |
| vpc_security_group_ids | List of security group IDs | `list(string)` | `[]` | no |
| subnet_id | VPC subnet ID | `string` | `null` | no |
| ami_id | AMI ID to use | `string` | `null` | no |
| root_block_device_encrypted | Whether to encrypt the root block device | `bool` | `true` | no |
| associate_public_ip_address | Whether to associate a public IP | `bool` | `false` | no |
| enable_detailed_monitoring | Enable detailed monitoring | `bool` | `false` | no |
| enable_cloudwatch_alarms | Whether to create CloudWatch alarms | `bool` | `false` | no |
| user_data_template | Name of user data template file | `string` | `null` | no |
| user_data_variables | Variables for user data template | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_arn | ARN of the EC2 instance |
| instance_state | State of the EC2 instance |
| private_ip | Private IP address of the instance |
| public_ip | Public IP address of the instance |
| security_controls_status | Status of implemented security controls |
| encryption_status | Encryption status for all storage volumes |

## Examples

The module includes several examples:

- **basic/**: Minimal configuration example
- **standalone/**: Self-contained example with security group creation

## Security Considerations

1. **Encryption**: All EBS volumes are encrypted by default
2. **IMDSv2**: Instance Metadata Service v2 is enforced by default
3. **Network**: Public IP association is disabled by default
4. **Monitoring**: Detailed monitoring and alarms can be enabled
5. **Termination Protection**: Can be enabled for production environments

## Compliance

This module is designed to meet:

- AWS Security Best Practices
- CCMS (Cloud Configuration Management Standards)
- Enterprise security requirements
- Regulatory compliance standards

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| random | >= 3.1 |
| null | >= 3.0 |

## License

This module is provided under the MIT License.