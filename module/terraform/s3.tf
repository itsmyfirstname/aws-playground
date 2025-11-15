resource "aws_s3_bucket" "truenas" {
  bucket = "mehays-truenas-backups"
}

resource "aws_s3_bucket" "site" {
  bucket = "mehays-site"
}

resource "aws_s3_bucket_website_configuration" "site"  {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "truenas_lifecycle" {
  bucket = aws_s3_bucket.truenas.id

  rule {
    id = "glacier-transition"
    status = "Enabled"
    transition {
      storage_class = "GLACIER"
      days = 30
    }
    transition {
      days          = 120
      storage_class = "DEEP_ARCHIVE"
    }
  }
}
