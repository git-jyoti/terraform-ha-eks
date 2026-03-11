output "kms_key_arn" {
  value = aws_kms_key.eks.arn
}

output "cluster_sg_id" {
  value = aws_security_group.cluster.id
}

output "node_sg_id" {
  value = aws_security_group.nodes.id
}
