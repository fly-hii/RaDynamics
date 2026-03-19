# S3 Enhanced Module - Basic Example

This example demonstrates the basic usage of the S3 Enhanced module with minimal configuration.

## Overview

This example creates:
- S3 bucket with AES-256 encryption
- Versioning enabled
- Public access blocked
- SSL-only access enforced
- CCMS-compliant tagging

## Usage

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- AWS provider >= 5.0

### Deployment Steps

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review the plan:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **Clean up (when done):**
   ```bash
   terraform destroy
   ```

### Customization

You can customize the deployment by setting variables:

```bash
terraform apply \
  -var="bucket_name_prefix=my-custom-bucket" \
  -var="environment=prod" \
  -var="cost_center=finance" \
  -var="owner=my-team"
```

Or create a `terraform.tfvars` file:

```hcl
bucket_name_prefix = "my-custom-bucket"
environment        = "prod"
cost_center       = "finance"
project_name      = "my-project"
owner            = "my-team"
business_unit    = "finance"
application_name = "my-app"
data_classification = "confidential"
```

## Configuration

### Required Variables
- `bucket_name_prefix`: Prefix for the bucket name (will have random suffix added)
- `environment`: Environment designation (dev, qa, test, staging, prod)

### CCMS Compliance Variables
- `cost_center`: Cost center for billing
- `project_name`: Project identification
- `owner`: Resource owner
- `business_unit`: Organizational unit
- `application_name`: Application identification
- `data_classification`: Data sensitivity level

## Security Features

This basic example includes:
- ✅ Server-side encryption (AES-256)
- ✅ Versioning enabled
- ✅ Public access blocked
- ✅ SSL-only access enforced
- ✅ CCMS-compliant tagging

## Outputs

The example provides the following outputs:
- `bucket_id`: S3 bucket identifier
- `bucket_arn`: S3 bucket ARN
- `bucket_domain_name`: Bucket domain name
- `bucket_regional_domain_name`: Regional domain name
- `bucket_region`: AWS region
- `encryption_configuration`: Encryption settings
- `versioning_configuration`: Versioning settings
- `public_access_block`: Public access settings
- `security_controls_status`: Security controls status
- `ccms_compliance_tags`: Applied CCMS tags

## Cost Considerations

This basic configuration uses:
- Standard storage class
- AES-256 encryption (no additional KMS costs)
- Versioning (additional storage for versions)
- No lifecycle policies (manual cleanup required)

Estimated monthly cost for 1GB of data: ~$0.025

## Next Steps

After deploying this basic example, you might want to:
1. Explore the advanced example with more features
2. Implement lifecycle policies for cost optimization
3. Add cross-region replication for disaster recovery
4. Enable advanced monitoring and analytics

## Support

For issues or questions:
1. Review the main module documentation
2. Check AWS CloudTrail logs for API errors
3. Validate AWS permissions and credentials
4. Consult the module's security controls documentation