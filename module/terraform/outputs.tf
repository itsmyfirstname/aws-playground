# CloudFront Distribution Domain Name - Main URL for the static site
output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

# CloudFront Distribution ID - Useful for cache invalidation
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

# CloudFront Distribution ARN
output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.arn
}

# S3 Bucket Name for the static site
output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site"
  value       = aws_s3_bucket.site.id
}

# S3 Bucket Regional Domain Name
output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.site.bucket_regional_domain_name
}

# S3 Bucket ARN
output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.site.arn
}

# Website URL
output "website_url" {
  description = "URL of the static website via CloudFront"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

# TrueNAS Backup Bucket Name
output "truenas_bucket_name" {
  description = "Name of the TrueNAS backup S3 bucket"
  value       = aws_s3_bucket.truenas.id
}
