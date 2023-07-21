provider "aws" {
  alias  = "alternate_region"
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

data "aws_region" "alternate" {
  provider = aws.alternate_region
}

resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_acm_certificate_validation" "alb_cert_validation" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_validation : record.fqdn]
}


resource "aws_acm_certificate" "cert" {
  provider = aws.alternate_region
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    Environment = "us-east-1"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.alternate_region
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_validation : record.fqdn]
}