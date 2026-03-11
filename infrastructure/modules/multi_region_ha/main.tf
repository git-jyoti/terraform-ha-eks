# Multi-region HA Module
# This module could handle global resources or cross-region connections
resource "aws_ssm_parameter" "cluster_endpoint" {
  name  = "/ha-eks/${var.region}/endpoint"
  type  = "String"
  value = var.cluster_endpoint
}
