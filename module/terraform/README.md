# AWS Static Site Deployment with Terraform

This Terraform configuration deploys a static website using AWS S3 for storage and CloudFront for global content distribution. The setup provides a secure, scalable, and cost-effective solution for hosting static websites.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│   Static Files  │───▶│  S3 Bucket       │───▶│  CloudFront     │
│   (HTML/CSS/JS) │    │  (Private)       │    │  Distribution   │
│                 │    │                  │    │  (Global CDN)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │                  │    │                 │
                       │  Origin Access   │    │   HTTPS Only    │
                       │  Control (OAC)   │    │   Website       │
                       │                  │    │                 │
                       └──────────────────┘    └─────────────────┘
```

## Features

- ✅ **Secure**: S3 bucket is private with CloudFront Origin Access Control (OAC)
- ✅ **Fast**: Global content distribution via CloudFront CDN
- ✅ **HTTPS**: Automatic HTTPS with CloudFront default certificate
- ✅ **Cost-Optimized**: Intelligent caching and storage lifecycle management
- ✅ **Automated**: File uploads and cache invalidation
- ✅ **Scalable**: Handles traffic spikes automatically
- ✅ **Error Handling**: Custom 404 error page

## Prerequisites

### Required Software
- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- [AWS CLI](https://aws.amazon.com/cli/) (configured with credentials)
- Bash shell (for deployment script)

### AWS Requirements
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Permissions for S3, CloudFront, and IAM operations

### Required AWS Permissions
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "cloudfront:*",
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
```

## Quick Start

1. **Configure AWS credentials**:
   ```bash
   aws configure
   ```

2. **Update configuration** (optional):
   Edit `variables.tf` to customize bucket names, regions, etc.

3. **Deploy**:
   ```bash
   ./deploy.sh deploy
   ```

4. **Access your site**:
   The deployment will output the CloudFront URL where your site is available.

## Configuration

### Variables

You can customize the deployment by modifying these variables in `variables.tf`:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for resources | `us-east-1` | No |
| `environment` | Environment name | `production` | No |
| `site_bucket_name` | S3 bucket name for website | `mehays-site` | No |
| `truenas_bucket_name` | S3 bucket name for backups | `mehays-truenas-backups` | No |
| `site_source_path` | Local path to site files | `../../site` | No |
| `cloudfront_price_class` | CloudFront price class | `PriceClass_100` | No |
| `enable_ipv6` | Enable IPv6 for CloudFront | `true` | No |
| `custom_domain` | Custom domain name | `""` | No |
| `acm_certificate_arn` | ACM certificate ARN | `""` | No |

### Custom Domain Setup

To use a custom domain:

1. **Request ACM certificate** (must be in `us-east-1` region):
   ```bash
   aws acm request-certificate \
     --domain-name yourdomain.com \
     --subject-alternative-names "*.yourdomain.com" \
     --validation-method DNS \
     --region us-east-1
   ```

2. **Update variables**:
   ```hcl
   custom_domain = "yourdomain.com"
   acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."
   ```

3. **Update DNS**:
   Create a CNAME record pointing your domain to the CloudFront distribution domain.

## Deployment Commands

The `deploy.sh` script provides several commands:

### Full Deployment
```bash
./deploy.sh deploy
```
Runs the complete deployment process: init, plan, apply, and cache invalidation.

### Individual Commands
```bash
# Initialize Terraform
./deploy.sh init

# Create deployment plan
./deploy.sh plan

# Apply existing plan
./deploy.sh apply

# Show deployment outputs
./deploy.sh outputs

# Invalidate CloudFront cache
./deploy.sh invalidate

# Validate site files
./deploy.sh validate

# Destroy infrastructure
./deploy.sh destroy
```

## File Structure

```
aws-playground/
├── site/                     # Static website files
│   ├── index.html           # Main page
│   ├── error.html           # 404 error page
│   └── assets/              # CSS, JS, images
├── module/terraform/        # Terraform configuration
│   ├── backend.tf          # Remote state configuration
│   ├── provider.tf         # AWS provider configuration
│   ├── variables.tf        # Input variables
│   ├── s3.tf              # S3 and CloudFront resources
│   ├── outputs.tf         # Output values
│   ├── deploy.sh          # Deployment script
│   └── README.md          # This file
```

## Updating Content

### Method 1: Re-run Deployment
After updating files in the `site/` directory:
```bash
./deploy.sh deploy
```

### Method 2: Manual S3 Upload + Cache Invalidation
```bash
# Upload new files
aws s3 sync ../site/ s3://your-bucket-name/ --delete

# Invalidate cache
./deploy.sh invalidate
```

## Cost Optimization

### S3 Storage Classes
- The configuration includes intelligent tiering for the TrueNAS backup bucket
- Website files use standard storage for fast access

### CloudFront Price Classes
- `PriceClass_100`: US, Canada, Europe (lowest cost)
- `PriceClass_200`: All locations except most expensive
- `PriceClass_All`: All global locations (highest performance)

### Estimated Monthly Costs
For a typical small website (< 1GB, < 10k requests/month):
- S3 Storage: ~$0.02
- CloudFront: ~$0.50
- **Total: ~$0.52/month**

## Security Features

### S3 Security
- ✅ Bucket is completely private (no public access)
- ✅ Server-side encryption enabled
- ✅ Versioning enabled
- ✅ Access only via CloudFront OAC

### CloudFront Security
- ✅ HTTPS enforced (HTTP redirects to HTTPS)
- ✅ TLS 1.2+ minimum
- ✅ Origin Access Control (OAC) prevents direct S3 access
- ✅ Custom error pages prevent information disclosure

## Monitoring and Logs

### CloudFront Metrics
Available in CloudWatch:
- Requests
- Bytes Downloaded
- Error Rate
- Cache Hit Rate

### Enable Access Logs (Optional)
To enable CloudFront access logs, add to the CloudFront distribution:
```hcl
logging_config {
  include_cookies = false
  bucket         = aws_s3_bucket.logs.bucket_domain_name
  prefix         = "cloudfront-logs/"
}
```

## Troubleshooting

### Common Issues

#### "Access Denied" Error
- **Cause**: S3 bucket policy or OAC misconfiguration
- **Solution**: Re-run deployment to ensure proper permissions

#### "Distribution Not Found"
- **Cause**: CloudFront distribution still deploying
- **Solution**: Wait 15-20 minutes for CloudFront deployment

#### "Certificate Validation Failed"
- **Cause**: ACM certificate not validated or in wrong region
- **Solution**: Ensure certificate is in `us-east-1` and validated

#### High Costs
- **Cause**: Large files or high traffic
- **Solution**: 
  - Optimize images and assets
  - Use appropriate CloudFront price class
  - Implement proper caching headers

### Debug Commands

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check S3 bucket contents
aws s3 ls s3://your-bucket-name/ --recursive

# Check CloudFront distribution status
aws cloudfront get-distribution --id DISTRIBUTION_ID

# View Terraform state
terraform show

# Check for Terraform issues
terraform validate
terraform plan
```

## Advanced Customization

### Adding Custom Cache Behaviors
Modify the CloudFront distribution in `s3.tf`:
```hcl
ordered_cache_behavior {
  path_pattern     = "/api/*"
  allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  cached_methods   = ["GET", "HEAD"]
  target_origin_id = "S3-${aws_s3_bucket.site.bucket}"
  
  cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
  
  viewer_protocol_policy = "redirect-to-https"
}
```

### Adding Response Headers
```hcl
response_headers_policy_id = "your-response-headers-policy-id"
```

### Multi-Environment Setup
Create separate `.tfvars` files:
```bash
# development.tfvars
environment = "development"
site_bucket_name = "mysite-dev"
cloudfront_price_class = "PriceClass_100"

# production.tfvars
environment = "production"
site_bucket_name = "mysite-prod"
cloudfront_price_class = "PriceClass_200"
```

Deploy with:
```bash
terraform plan -var-file="development.tfvars"
terraform apply -var-file="development.tfvars"
```

## Backup and Recovery

### State File Backup
- Terraform state is stored in S3 backend
- Enable versioning on the state bucket
- Regular backups are automatic

### Website Backup
- S3 versioning is enabled for website files
- Consider Cross-Region Replication for critical sites

## Performance Optimization

### Content Optimization
- Compress images (WebP format recommended)
- Minify CSS and JavaScript
- Use appropriate cache headers

### CloudFront Optimization
- Enable Gzip compression
- Use appropriate cache policies
- Consider HTTP/2 and HTTP/3 support

## Compliance and Governance

### Tags
All resources are tagged with:
- `Environment`
- `Project`
- `ManagedBy`

### Cost Allocation
Use AWS Cost Explorer with tags to track costs by environment or project.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review AWS CloudWatch logs
3. Validate Terraform configuration with `terraform validate`
4. Check AWS service status at https://status.aws.amazon.com/

## License

This configuration is provided as-is for educational and production use.