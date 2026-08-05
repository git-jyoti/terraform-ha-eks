output "cluster_role_arn" {
  description = "Existing EKS Cluster IAM Role ARN"
  value       = data.aws_iam_role.cluster.arn
}


output "node_role_arn" {
  description = "Existing EKS Node IAM Role ARN"
  value       = data.aws_iam_role.nodes.arn
}
