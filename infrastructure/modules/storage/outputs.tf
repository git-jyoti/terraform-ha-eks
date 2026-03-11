output "efs_id" {
  value = aws_efs_file_system.eks.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.eks.dns_name
}
