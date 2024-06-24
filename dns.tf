resource "aws_route53_zone" "main" {
  name = "webapp.clairepalmerpiano.co.uk"
}

resource "aws_acm_certificate" "certificate" {
  validation_method = "DNS"
  domain_name       = "webapp.clairepalmerpiano.co.uk"
}

resource "aws_route53_record" "records" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_alb.alb_module.dns_name
    zone_id                = aws_alb.alb_module.zone_id
    evaluate_target_health = true
  }
}
