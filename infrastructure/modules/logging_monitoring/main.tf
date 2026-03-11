resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/logs"
  retention_in_days = var.retention_days

  tags = var.tags
}

resource "aws_cloudwatch_query_definition" "eks_errors" {
  name = "EKS Errors"

  log_group_names = [
    aws_cloudwatch_log_group.eks.name
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /error/
| sort @timestamp desc
EOF
}
