resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "static-site-oac"
  description                       = "OAC for static website CloudFront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "S3-${aws_s3_bucket.site.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = var.enable_ipv6
  default_root_object = var.default_root_object
  comment             = "Static website CloudFront distribution"

  web_acl_id = "arn:aws:wafv2:us-east-1:294637015793:global/webacl/CreatedByCloudFront-8d4dd493/3416c0b1-8a8d-4dd9-a937-57755e078d91"
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.site.bucket}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d" # AWS Managed CachingOptimized policy

    # Custom error pages
    # dynamic "custom_error_response" {
    #   for_each = [
    #     {
    #       error_code         = 403
    #       response_code      = 404
    #       response_page_path = var.error_page_path
    #     },
    #     {
    #       error_code         = 404
    #       response_code      = 404
    #       response_page_path = var.error_page_path
    #     }
    #   ]
    #   content {
    #     error_code         = custom_error_response.value.error_code
    #     response_code      = custom_error_response.value.response_code
    #     response_page_path = custom_error_response.value.response_page_path
    #   }
    # }
  }

  # Price class for cost optimization
  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL certificate
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = var.viewer_cert_min_version
  }
}

//resource "aws_wafv2_web_acl_association" "example" {
//  resource_arn = aws_cloudfront_distribution.s3_distribution.arn
//  web_acl_arn  = aws_wafv2_web_acl.site.arn
//}
