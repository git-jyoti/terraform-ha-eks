resource "aws_efs_file_system" "eks" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true
  kms_key_id     = var.kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-efs"
    }
  )
}

resource "aws_efs_mount_target" "eks" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [var.efs_sg_id]
}
