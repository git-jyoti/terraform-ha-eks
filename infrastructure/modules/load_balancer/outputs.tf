output "alb_arn" {
  value = aws_lb.eks.arn
}

output "alb_dns_name" {
  value = aws_lb.eks.dns_name
}

output "certificate_arn" {
  value = aws_acm_certificate.eks.arn
}
