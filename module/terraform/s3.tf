resource "aws_s3_bucket" "truenas" {
  bucket = var.truenas_bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "truenas_lifecycle" {
  bucket = aws_s3_bucket.truenas.id

  rule {
    id     = "glacier-transition"
    status = "Enabled"

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    transition {
      days          = var.deep_archive_transition_days
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

resource "aws_s3_bucket" "site" {
  bucket = var.site_bucket_name
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.site]
}

# Upload index.html
resource "aws_s3_object" "site_html" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${var.site_source_path}/index.html"
  content_type = "text/html"
  etag         = filemd5("${var.site_source_path}/index.html")
}

resource "aws_s3_object" "site_error_html" {
  bucket       = aws_s3_bucket.site.id
  key          = "error.html"
  source       = "${var.site_source_path}/error.html"
  content_type = "text/html"
  etag         = filemd5("${var.site_source_path}/error.html")
}

resource "aws_s3_object" "site_css" {
  for_each = fileset(var.site_source_path, "*.css")

  bucket       = aws_s3_bucket.site.id
  key          = each.value
  source       = "${var.site_source_path}/${each.value}"
  content_type = "text/css"
  etag         = filemd5("${var.site_source_path}/${each.value}")
}

# Upload any JS files if they exist
resource "aws_s3_object" "site_js" {
  for_each = fileset(var.site_source_path, "*.js")

  bucket       = aws_s3_bucket.site.id
  key          = each.value
  source       = "${var.site_source_path}/${each.value}"
  content_type = "application/javascript"
  etag         = filemd5("${var.site_source_path}/${each.value}")
}

# Upload any image files if they exist
resource "aws_s3_object" "site_images" {
  for_each = fileset(var.site_source_path, "{*.png,*.jpg,*.jpeg,*.gif,*.svg,*.ico}")

  bucket = aws_s3_bucket.site.id
  key    = each.value
  source = "${var.site_source_path}/${each.value}"
  content_type = lookup({
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
  etag = filemd5("${var.site_source_path}/${each.value}")
}
