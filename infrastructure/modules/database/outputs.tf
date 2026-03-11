output "cluster_arn" {
  value = aws_rds_cluster.this.arn
}

output "global_cluster_id" {
  value = var.is_global_cluster ? aws_rds_global_cluster.this[0].id : null
}
