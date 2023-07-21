resource "aws_route53_zone" "app_zone" {
  name = var.domain
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.app_zone.zone_id
  name    = var.domain
  type    = "A"
  
  alias {
    name                   = "${aws_cloudfront_distribution.app_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.app_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.app_zone.zone_id
}
