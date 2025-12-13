# AWS Region
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# Environment
variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  default     = "production"
}

# Site S3 Bucket Name
variable "site_bucket_name" {
  description = "Name of the S3 bucket for the static website"
  type        = string
  default     = "mehays-site"
}

# TrueNAS S3 Bucket Name
variable "truenas_bucket_name" {
  description = "Name of the S3 bucket for TrueNAS backups"
  type        = string
  default     = "mehays-truenas-backups"
}

# Site Source Directory
variable "site_source_path" {
  description = "Local path to the static site files"
  type        = string
  default     = "../../site"
}

# CloudFront Price Class
variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200",
      "PriceClass_100"
    ], var.cloudfront_price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

# Enable IPv6 for CloudFront
variable "enable_ipv6" {
  description = "Enable IPv6 for CloudFront distribution"
  type        = bool
  default     = true
}

# Default Root Object
variable "default_root_object" {
  description = "Default root object for CloudFront distribution"
  type        = string
  default     = "index.html"
}

# Error Page Path
variable "error_page_path" {
  description = "Path to the error page"
  type        = string
  default     = "/error.html"
}

# TrueNAS Lifecycle - Days to Glacier
variable "glacier_transition_days" {
  description = "Number of days before transitioning TrueNAS backups to Glacier"
  type        = number
  default     = 30
}

# TrueNAS Lifecycle - Days to Deep Archive
variable "deep_archive_transition_days" {
  description = "Number of days before transitioning TrueNAS backups to Deep Archive"
  type        = number
  default     = 120
}

# Custom Domain (optional)
variable "custom_domain" {
  description = "Custom domain name for the static site (optional)"
  type        = string
  default     = ""
}

# ACM Certificate ARN (required if custom_domain is set)
variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for custom domain (required if custom_domain is set)"
  type        = string
  default     = ""
}

# Common Tags
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "aws-playground"
    ManagedBy = "terraform"
  }
}
