resource "aws_s3_bucket" "example" {
  bucket        = local.name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]
}

resource "aws_s3_bucket_policy" "example_allow_public_access" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.example,
    aws_s3_bucket_acl.example,
    aws_s3_bucket_public_access_block.example
  ]
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "aws_s3_object" "example" {
  for_each = { for file in local.files : file.path => file }
  bucket   = aws_s3_bucket.example.id
  key      = each.value.dest
  source   = each.value.path
  etag     = filemd5(each.value.path)
  content_type = lookup(
    local.content_types,
    ".${split(".", each.value.dest)[length(split(".", each.value.dest)) - 1]}",
    "application/octet-stream"
  )
}

resource "aws_s3_bucket" "web_log" {
  bucket        = "${local.name}-log"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "web_log" {
  bucket = aws_s3_bucket.web_log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "web_log" {
  bucket = aws_s3_bucket.web_log.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.web_log,
  ]
}
resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.example.id

  target_bucket = aws_s3_bucket.web_log.id
  target_prefix = "s3/"
}

resource "aws_s3_bucket_policy" "web_log" {
  bucket = aws_s3_bucket.web_log.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "s3:PutObject"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Resource = "${aws_s3_bucket.web_log.arn}/*",
      },
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }

  # error_document {
  #   key = "error.html"
  # }
}
