/* Storage */
resource "aws_s3_bucket" "static" {
    bucket = "${var.environment}-${var.app_name}-static"
    tags = {
        Name = "Static Bucket for Backend Resources"
        Environment = var.environment
    }
}

resource "aws_s3_bucket" "media" {
    bucket = "${var.environment}-${var.app_name}-media"
    tags = {
        Name = "Media Bucket for Backend Resources"
        Environment = var.environment
    }
}

resource "aws_s3_bucket" "frontend" {
    bucket = "${var.environment}-${var.app_name}-frontend"
    tags = {
        Name = "Frontend Bucket"
        Environment = var.environment
    }
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend_allow_public_get_object.json
}

data "aws_iam_policy_document" "frontend_allow_public_get_object" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.frontend.arn,
      "${aws_s3_bucket.frontend.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}


resource "aws_s3_bucket_acl" "media_private_acl" {
  bucket = aws_s3_bucket.media.id
  acl    = "private"
}