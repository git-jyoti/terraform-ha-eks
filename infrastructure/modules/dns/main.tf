resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = var.tags
}

resource "aws_route53_record" "eks" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }

  set_identifier = var.region
  latency_routing_policy {
    region = var.region
  }
}
